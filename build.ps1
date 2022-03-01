$Transfer_url='https://transferapp.frame.io/Frame.io-Transfer/6ab0c27d61d7cf8793b0357e6533ed81/latest/win32/x64/Frame.io+Transfer.exe'
$Transfer_dl='C:\Temp\Frame.io.Transfer.exe'

$NSIS_url='https://cfhcable.dl.sourceforge.net/project/nsis/NSIS%203/3.08/nsis-3.08-setup.exe'
$NSIS_dl='C:\Temp\nsis-3.08-setup.exe'

$Python_url='https://www.python.org/ftp/python/3.7.9/python-3.7.9-amd64.exe'
$Python_dl='C:\Temp\python-3.7.9-amd64.exe'
$Transfer_nsis='C:\Temp\Frame.io.Transfer.NSIS.exe'

$ProgressPreference = 'SilentlyContinue'

function CheckIsInstalled($prog) {
   $Check1=((gp "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*")).DisplayName -Match $prog).Length -gt 0
   $Check2=((gp "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*")).DisplayName -Match $prog).Length -gt 0
   if ($Check1.Length -gt 0) { 
       return $true;
   }
   if ($Check2.Length -gt 0) {
       return $true;
   }
   return $false;
}

# Check to see if NSIS is installed
if (-Not CheckIsInstalled("Nullsoft Install System")) {
    # Install NSIS
    Write-Host "NSIS not installed, installing now"
    Invoke-WebRequest -Uri $NSIS_url -OutFile $NSIS_dl
    Start-Process -FilePath $NSIS_dl -ArgumentList "/S" -Wait
}

# Check to see if Python 3 is installed
if (-Not CheckIsInstalled("Python 3")) {
    # Install python3.7.9
    Write-Host "Python 3 not installed, installing now"
    Invoke-WebRequest -Uri $Python_url -OutFile $Python_dl
    Start-Process -FilePath $Python_dl -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
}

Invoke-WebRequest -Uri $Transfer_url -OutFile $Transfer_dl
Start-Process -FilePath 'python' -ArgumentList "squirrel-to-nsis.py $Transfer_dl $Transfer_nsis"
Write-Host "NSIS installer can be found at ${Transfer_nsis}"
