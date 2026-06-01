@echo off
setlocal

set APP_NAME=VLighter
set INSTALL_DIR=%LOCALAPPDATA%\%APP_NAME%
set REPO_URL=https://github.com/innovainformationtechnologies/VLighter.git
set TEMP_DIR=%TEMP%\%APP_NAME%_install

echo Installing %APP_NAME%...
mkdir "%TEMP_DIR%" 2>nul

:: ── Python ────────────────────────────────────────────────────────────────────
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo Python not found. Downloading installer...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe' -OutFile '%TEMP_DIR%\python_installer.exe'"
    if %errorlevel% neq 0 goto :fail_download

    echo Installing Python...
    "%TEMP_DIR%\python_installer.exe" /quiet InstallAllUsers=0 PrependPath=1 Include_launcher=0
    if %errorlevel% neq 0 goto :fail
    echo Python installed.
)

:: ── Git ───────────────────────────────────────────────────────────────────────
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo Git not found. Downloading installer...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe' -OutFile '%TEMP_DIR%\git_installer.exe'"
    if %errorlevel% neq 0 goto :fail_download

    echo Installing Git...
    "%TEMP_DIR%\git_installer.exe" /SILENT /NORESTART
    if %errorlevel% neq 0 goto :fail
    echo Git installed.
    set "PATH=%PATH%;C:\Program Files\Git\cmd"
)

:: ── Pipenv ────────────────────────────────────────────────────────────────────
where pipenv >nul 2>&1
if %errorlevel% neq 0 (
    echo Pipenv not found. Installing...
    pip install pipenv
    if %errorlevel% neq 0 goto :fail
    echo Pipenv installed.
)

:: ── FFmpeg ───────────────────────────────────────────────────────────────────
where ffmpeg >nul 2>&1
if %errorlevel% neq 0 (
    echo FFmpeg not found. Downloading...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile '%TEMP_DIR%\ffmpeg.zip'"
    if %errorlevel% neq 0 goto :fail_download

    echo Extracting FFmpeg...
    powershell -Command "Expand-Archive -Path '%TEMP_DIR%\ffmpeg.zip' -DestinationPath '%TEMP_DIR%\ffmpeg'"
    if %errorlevel% neq 0 goto :fail

    :: Copy ffmpeg.exe to install dir so it's always findable
    for /d %%i in ("%TEMP_DIR%\ffmpeg\ffmpeg-*") do copy /y "%%i\bin\ffmpeg.exe" "%INSTALL_DIR%\ffmpeg.exe"
    if %errorlevel% neq 0 goto :fail
    echo FFmpeg installed.
)

:: ── Clone ─────────────────────────────────────────────────────────────────────
if exist "%INSTALL_DIR%" (
    echo Directory already exists, skipping clone...
) else (
    echo Cloning repository...
    git clone %REPO_URL% "%INSTALL_DIR%"
    if %errorlevel% neq 0 goto :fail
)

:: ── Install dependencies ──────────────────────────────────────────────────────
cd /d "%INSTALL_DIR%"
echo Installing dependencies...
pipenv install
if %errorlevel% neq 0 goto :fail

:: ── Copy launcher ─────────────────────────────────────────────────────────────
echo Copying launcher...
copy /y "%~dp0launch.bat" "%INSTALL_DIR%\launch.bat"
if %errorlevel% neq 0 goto :fail

:: ── Desktop shortcut ──────────────────────────────────────────────────────────
echo Creating desktop shortcut...
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%USERPROFILE%\Desktop\%APP_NAME%.lnk'); $s.TargetPath = '%INSTALL_DIR%\launch.bat'; $s.WorkingDirectory = '%INSTALL_DIR%'; $s.Save()"
if %errorlevel% neq 0 goto :fail

:: ── Cleanup ───────────────────────────────────────────────────────────────────
rmdir /s /q "%TEMP_DIR%" 2>nul

echo.
echo Done! Shortcut created on Desktop.
pause
exit /b 0

:: ── Failure handlers ──────────────────────────────────────────────────────────
:fail_download
echo.
echo Failed to download a required installer. Please check your internet connection and re-run.
pause
exit /b 1

:fail
echo.
echo Installation failed. This can happen after Git or Python is freshly installed.
echo Please close this window and re-run the installer.
pause
exit /b 1