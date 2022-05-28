Unicode True
Name "Discord"
Outfile "DiscordSetup.exe"
Icon "img\icon.ico"
UninstallIcon "img\icon.ico"
InstallDir "$PROGRAMFILES\Discord"
Section
SetOutPath "$INSTDIR"
File /r lib\net45
CreateShortcut "$SMPROGRAMS\Discord.lnk"                  "$INSTDIR\lib\net45\Discord.exe"
WriteUninstaller "$INSTDIR\uninstall.exe"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Discord" "DisplayName" "Discord"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Discord"                  "UninstallString" "$\"$INSTDIR\uninstall.exe$\" "
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Discord"                  "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
SectionEnd
Section "Uninstall"
Delete "$INSTDIR\uninstall.exe"
Delete "$SMPROGRAMS\Discord.lnk"
RMDir /r "$INSTDIR"
DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Discord"
SectionEnd
