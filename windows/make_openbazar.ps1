
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

# Create the frozen python server
echo "Creating python virtual environment in venv"
virtualenv venv

./venv/scripts/activate
easy_install https://openbazaar.org/downloads/PyNaCl-0.3.0-py2.7-win32.egg.zip
move  .\venv\Lib\site-packages\PyNaCl-0.3.0-py2.7-win32.egg\PyNaCl-0.3.0-py2.7-win32.egg\* .\venv\Lib\site-packages\PyNaCl-0.3.0-py2.7-win32.egg
pip install -r requirements.txt
pip install -r ../OpenBazaar-Server/requirements.txt
pyinstaller ../OpenBazaar-Server/openbazaard.py --icon=icon.ico --name=OpenbazaarServer
copy ../OpenBazaar-Server/ob.cfg ./dist/OpenbazaarServer/
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
