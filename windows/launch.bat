@echo off
setlocal

set APP_NAME=VLighter
set INSTALL_DIR=%LOCALAPPDATA%\%APP_NAME%

cd /d "%INSTALL_DIR%"

echo Checking for updates...
git pull

echo Installing dependencies
pipenv install

echo Launching %APP_NAME%...
pipenv run python main.py