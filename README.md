# Windows Code Signing Test

Petit projet pour tester la signature de code Windows avec **Microsoft Azure Artifact Signing** (anciennement Trusted Signing) et observer comment Windows (Edge, SmartScreen, Defender) réagit face à un exécutable signé ou non.

## Contenu

| Fichier | Rôle |
|---|---|
| `hello.c` | Programme de test : affiche une simple boîte de dialogue (`MessageBox`) |
| `docs/images/` | Captures d'écran des tests |

Les `.exe` ne sont pas versionnés (`.gitignore`). Ils sont publiés dans les [Releases](../../releases) du dépôt.

## Compilation

Avec MinGW-w64 (GCC) :

```bash
gcc -O2 -mwindows -s hello.c -o HelloNotSign.exe
```

## Test 1 : exécutable non signé (`HelloNotSign.exe`)

L'exe a été publié dans une release GitHub, puis téléchargé avec Microsoft Edge pour reproduire un vrai téléchargement (le fichier reçoit alors le *Mark of the Web*). Le programme n'a même pas pu être lancé : Windows bloque le fichier dès le téléchargement.

### Ce qui se passe

**1. Edge avertit que le fichier est rare.**
Dès le téléchargement, Edge affiche « *HelloNotSign.exe isn't commonly downloaded. Make sure you trust HelloNotSign.exe before you open it.* ». Le menu propose *Delete*, *Keep*, *Report this file as safe*.

![Avertissement au téléchargement](docs/images/01-unsigned-download-warning.png)

**2. SmartScreen ne peut pas vérifier le fichier.**
En cliquant sur l'avertissement, Microsoft Defender SmartScreen explique qu'il ne peut pas vérifier que le fichier est sûr car il est peu téléchargé. L'éditeur est affiché comme **« Publisher: Unknown »**. Le bouton par défaut est *Delete* ; il faut ouvrir le menu déroulant pour trouver *Keep anyway*.

![Dialogue SmartScreen](docs/images/02-unsigned-smartscreen-dialog.png)

**3. Le téléchargement échoue : « Virus detected ».**
Après avoir choisi de conserver le fichier, le téléchargement est tout de même refusé avec le message « *Couldn't download - Virus detected* » (un autre essai affiche simplement « *Download error* »).

![Virus detected](docs/images/03-unsigned-virus-detected.png)

### Pourquoi

- **Aucune signature** : sans certificat, Windows ne peut pas identifier l'éditeur (*Publisher: Unknown*).
- **Aucune réputation** : SmartScreen juge un fichier par sa réputation (nombre de téléchargements, éditeur connu). Un exe tout neuf n'en a aucune, d'où « isn't commonly downloaded ».
- **Détection antivirus** : un petit exécutable natif, non signé, inconnu et téléchargé depuis un hébergement public correspond à un profil que les heuristiques de Defender traitent comme suspect. Le message « Virus detected » est ici un **faux positif** : le code source (`hello.c`) ne fait qu'afficher une boîte de dialogue.

Ces trois éléments s'additionnent : SmartScreen est un avertissement que l'utilisateur peut contourner, mais l'analyse antivirus, elle, bloque purement et simplement le fichier.

## Test 2 : exécutable signé (à venir)

Même programme, signé avec Azure Artifact Signing, publié dans une release puis téléchargé de la même façon, pour comparer le comportement.
