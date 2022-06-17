$Transfer_url='https://release.axocdn.com/win64/GitKrakenSetup.exe'
$Transfer_dl='C:\Temp\GitKrakenSetup.exe'

$NSIS_url='https://cfhcable.dl.sourceforge.net/project/nsis/NSIS%203/3.08/nsis-3.08-setup.exe'
$NSIS_dl='C:\Temp\nsis-3.08-setup.exe'

$Python_url='https://www.python.org/ftp/python/3.7.9/python-3.7.9-amd64.exe'
$Python_dl='C:\Temp\python-3.7.9-amd64.exe'
$Transfer_nsis='C:\Temp\GitKraken.NSIS.exe'

$ProgressPreference = 'SilentlyContinue'

function CheckIsInstalled($prog) {
   $Check1=((gp "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*").DisplayName -Match $prog).Length -gt 0
   $Check2=((gp "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*").DisplayName -Match $prog).Length -gt 0
   if ($Check1.Length -gt 0) { 
       return $true;
   }
   if ($Check2.Length -gt 0) {
       return $true;
   }
   return $false;
}

Write-Host "Checking dependencies"
# Check to see if NSIS is installed
$NullsoftInstalled = CheckIsInstalled("Nullsoft Install System")
if (-Not $NullsoftInstalled) {
    # Install NSIS
    Write-Host "NSIS not installed, installing now"
    Invoke-WebRequest -Uri $NSIS_url -OutFile $NSIS_dl
    Start-Process -FilePath $NSIS_dl -ArgumentList "/S" -Wait
}
Write-Host "NSIS installed"

$Python3Installed = CheckIsInstalled("Python 3")
# Check to see if Python 3 is installed
if (-Not $Python3Installed) {
    # Install python3.7.9
    Write-Host "Python 3 not installed, installing now"
    Invoke-WebRequest -Uri $Python_url -OutFile $Python_dl
    Start-Process -FilePath $Python_dl -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
}
Write-Host "Python 3 installed"

Write-Host "Downloading GitKraken"
Invoke-WebRequest -Uri $Transfer_url -OutFile $Transfer_dl
Write-Host "Executing conversion"
python "squirrel-to-nsis.py" $Transfer_dl $Transfer_nsis
# Start-Process -FilePath .\squirrel-to-nsis.py -ArgumentList "$Transfer_dl $Transfer_nsis"
Write-Host "NSIS installer can be found at ${Transfer_nsis}"
