#include <windows.h>

int WINAPI WinMain(HINSTANCE hInst, HINSTANCE hPrev, LPSTR cmd, int show)
{
    MessageBoxA(NULL, "Bonjour ! Ce programme a ete signe avec Azure Code Signing.", "HelloSigningTest", MB_OK | MB_ICONINFORMATION);
    return 0;
}
