Unicode True
Name "GitKraken"
Outfile "GitKrakenSetup.exe"
Icon "img\icon.ico"
UninstallIcon "img\icon.ico"
InstallDir "$PROGRAMFILES\GitKraken"
Section
SetOutPath "$INSTDIR"
File /r lib\net45
CreateShortcut "$SMPROGRAMS\GitKraken.lnk"                  "$INSTDIR\lib\net45\GitKraken.exe"
WriteUninstaller "$INSTDIR\uninstall.exe"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GitKraken" "DisplayName" "GitKraken"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GitKraken"                  "UninstallString" "$\"$INSTDIR\uninstall.exe$\" "
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GitKraken"                  "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
SectionEnd
Section "Uninstall"
Delete "$INSTDIR\uninstall.exe"
Delete "$SMPROGRAMS\GitKraken.lnk"
RMDir /r "$INSTDIR"
DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GitKraken"
SectionEnd
