
# First make sure that all requirements are installed
./checkRequirements.ps1
if ($LastExitCode -gt 0)
{
    exit
}

#virtualenv is not in PATH by default so we must add it for the current session
$pythonCommand = Get-Command python
$pythonPath = Split-Path $pythonCommand.source
$Env:Path += ";" + $pythonPath + "/scripts/"

# Create the python environment needed to create the exe distribution
echo "Creating python virtual environment in venv"
virtualenv venv
./venv/scripts/activate
easy_install https://openbazaar.org/downloads/PyNaCl-0.3.0-py2.7-win32.egg.zip
move  .\venv\Lib\site-packages\PyNaCl-0.3.0-py2.7-win32.egg\PyNaCl-0.3.0-py2.7-win32.egg\* .\venv\Lib\site-packages\PyNaCl-0.3.0-py2.7-win32.egg
pip install -r requirements.txt
pip install -r ../OpenBazaar-Server/requirements.txt

# Create the frozen python server
pyinstaller ../OpenBazaar-Server/openbazaard.py --icon=icon.ico --name=OpenbazaarServer
copy ../OpenBazaar-Server/ob.cfg ./dist/OpenbazaarServer/

# Create the tray app executable
echo 'Compiling tray application'
pyinstaller --onefile --windowed systray.py --icon=systray.ico --name=OpenBazaar
copy ./systray.ico ./dist

deactivate

# Create the Electron application bundle
echo 'Compiling node packages'
cd ../OpenBazaar-Client
npm install
npm install electron-packager
echo 'Packaging Electron application'
./node_modules/.bin/electron-packager . OpenBazaarClient --platform=win32 --arch=ia32 --version=0.33.9 --asar --icon=../windows/icon.ico --overwrite

Rename-Item ./OpenBazaarClient-win32-ia32 OpenBazaarClient
move ./OpenBazaarClient ../windows/dist/
cd ../windows

# Bundle gpg.exe
new-item ./dist/gpg -itemtype directory
new-item ./dist/gpg/pub -itemtype directory
$gpgCommand = Get-Command gpg
$gpgPath = Split-Path $gpgCommand.source
copy $gpgCommand.source ./dist/gpg/pub
copy $gpgPath/../gpg2.exe ./dist/gpg
copy $gpgPath/../gpgconf.exe ./dist/gpg
copy $gpgPath/../libadns-1.dll ./dist/gpg
copy $gpgPath/../libassuan-0.dll ./dist/gpg
copy $gpgPath/../libgcrypt-20.dll ./dist/gpg
copy $gpgPath/../libgpg-error-0.dll ./dist/gpg
copy $gpgPath/../libiconv-2.dll ./dist/gpg

#Create the installer
makensis ob.nsi