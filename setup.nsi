Unicode True
Name "Frame.io Transfer"
Outfile "Frame.io Transfer Setup.exe"
Icon "img\icon.ico"
UninstallIcon "img\icon.ico"
InstallDir "$PROGRAMFILES\Frame.io Transfer"
Section
SetOutPath "$INSTDIR"
File /r lib\net45
CreateShortcut "$SMPROGRAMS\Frame.io Transfer.lnk"                  "$INSTDIR\net45\Frame.io Transfer.exe"
WriteUninstaller "$INSTDIR\uninstall.exe"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Transfer" "DisplayName" "Frame.io Transfer"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Transfer"                  "UninstallString" "$\"$INSTDIR\uninstall.exe$\" "
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Transfer"                  "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
SectionEnd
Section "Uninstall"
Delete "$INSTDIR\uninstall.exe"
Delete "$SMPROGRAMS\Frame.io Transfer.lnk"
RMDir /r "$INSTDIR"
DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Transfer"
SectionEnd
