Unicode True
Name "Input ACE Axon Investigate"
Outfile "Input ACE Axon Investigate Setup.exe"
Icon "img\icon.ico"
UninstallIcon "img\icon.ico"
InstallDir "$PROGRAMFILES\INPUT"
Section
SetShellVarContext all
SetOutPath "$INSTDIR"
File /r lib\native
CreateShortcut "$SMPROGRAMS\Input ACE Axon Investigate.lnk"                  "$INSTDIR\-iNPUT.exe"
WriteUninstaller "$INSTDIR\uninstall.exe"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\INPUT" "DisplayName" "Input ACE Axon Investigate"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\INPUT"                  "UninstallString" "$\"$INSTDIR\uninstall.exe$\" "
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\INPUT"                  "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
SectionEnd
Section "Uninstall"
Delete "$INSTDIR\uninstall.exe"
Delete "$SMPROGRAMS\Input ACE Axon Investigate.lnk"
RMDir /r "$INSTDIR"
DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\INPUT"
SectionEnd
