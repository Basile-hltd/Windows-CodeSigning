<#
.SYNOPSIS
    Compile un fichier C avec GCC puis signe l'exe avec Azure Artifact Signing.

.EXAMPLE
    .\compileAndSign.ps1 hello.c -o HelloSigned.exe
#>
param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Source,

    [Parameter(Mandatory)]
    [Alias('o')]
    [string]$Output
)

$ErrorActionPreference = 'Stop'

$root     = $PSScriptRoot
$dlib     = Join-Path $root 'tools\artifactsigning-client\bin\x64\Azure.CodeSigning.Dlib.dll'
$metadata = Join-Path $root 'metadata.json'
$signtool = Get-ChildItem 'C:\Program Files (x86)\Windows Kits\10\bin\*\x64\signtool.exe' -ErrorAction SilentlyContinue |
    Sort-Object FullName -Descending | Select-Object -First 1 -ExpandProperty FullName

if (-not (Test-Path $Source))   { throw "Source introuvable : $Source" }
if (-not (Test-Path $dlib))     { throw "Plugin Dlib introuvable : $dlib" }
if (-not (Test-Path $metadata)) { throw "metadata.json introuvable : $metadata" }
if (-not $signtool)             { throw "signtool.exe introuvable (installer le Windows SDK)" }
if (-not (Get-Command gcc -ErrorAction SilentlyContinue)) { throw "gcc introuvable dans le PATH" }
if (-not (Get-Command az -ErrorAction SilentlyContinue))  { throw "Azure CLI introuvable (az)" }

# La signature utilise les identifiants Azure CLI : verifier qu'on est connecte
az account show --output none 2>$null
if ($LASTEXITCODE -ne 0) { throw "Non connecte a Azure. Lance d'abord : az login" }

Write-Host "==> Compilation de $Source -> $Output"
gcc -O2 -mwindows -s $Source -o $Output
if ($LASTEXITCODE -ne 0) { throw "Echec de la compilation" }

Write-Host "==> Signature de $Output"
& $signtool sign /v /fd SHA256 `
    /tr 'http://timestamp.acs.microsoft.com' /td SHA256 `
    /dlib $dlib /dmdf $metadata `
    $Output
if ($LASTEXITCODE -ne 0) { throw "Echec de la signature" }

Write-Host "==> Verification"
& $signtool verify /pa /v $Output
if ($LASTEXITCODE -ne 0) { throw "La verification de la signature a echoue" }

Write-Host "OK : $Output compile et signe."
