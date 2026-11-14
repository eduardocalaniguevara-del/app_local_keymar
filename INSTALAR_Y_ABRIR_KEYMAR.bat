@echo off
title Instalador Autonomo - Recepcion Hostal Keymar
cd /d "%~dp0"

echo ====================================================================
echo   INSTALACION AUTOMATICA - HOSTAL KEYMAR
echo   Hoja vinculada: 1QwYyAEfN8qERX0ynckWda7Dqua41L0pTD-IRnoyQZYI
echo ====================================================================
echo.

set "DEST_DIR=C:\Recepcion_Keymar_Local"
set "GIT_DIR=C:\Hostal_Sistema\tools\mingit"
set "GIT_EXE=%GIT_DIR%\cmd\git.exe"

:: 1. Detectar Python REAL (ignorando WindowsApps)
set "PY_EXE="
if exist "%LocalAppData%\Programs\Python\Python312\python.exe" set "PY_EXE=%LocalAppData%\Programs\Python\Python312\python.exe"
if exist "%LocalAppData%\Programs\Python\Python311\python.exe" set "PY_EXE=%LocalAppData%\Programs\Python\Python311\python.exe"
if exist "%LocalAppData%\Programs\Python\Python313\python.exe" set "PY_EXE=%LocalAppData%\Programs\Python\Python313\python.exe"
if exist "%LocalAppData%\Python\pythoncore-3.14-64\python.exe" set "PY_EXE=%LocalAppData%\Python\pythoncore-3.14-64\python.exe"
if exist "C:\Python312\python.exe" set "PY_EXE=C:\Python312\python.exe"
if exist "C:\Python311\python.exe" set "PY_EXE=C:\Python311\python.exe"
if exist "C:\Program Files\Python312\python.exe" set "PY_EXE=C:\Program Files\Python312\python.exe"
if exist "C:\Program Files\Python311\python.exe" set "PY_EXE=C:\Program Files\Python311\python.exe"

if defined PY_EXE goto py_listo

echo [1/5] Python no detectado. Descargando e instalando Python 3.12 (liviano con curl)...
curl.exe -L -o "%TEMP%\python_installer.exe" "https://www.python.org/ftp/python/3.12.8/python-3.12.8-amd64.exe"
if exist "%TEMP%\python_installer.exe" (
    echo Instalando Python 3.12 silenciosamente (espere 1 a 2 minutos)...
    "%TEMP%\python_installer.exe" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0 Include_pip=1
    del /f /q "%TEMP%\python_installer.exe" >nul 2>&1
)
if exist "%LocalAppData%\Programs\Python\Python312\python.exe" set "PY_EXE=%LocalAppData%\Programs\Python\Python312\python.exe"

:py_listo
echo [1/5] Python listo: %PY_EXE%

:: 2. Copiar archivos a C:\Recepcion_Keymar_Local
echo [2/5] Instalando archivos en %DEST_DIR%...
if not exist "%DEST_DIR%" mkdir "%DEST_DIR%"
xcopy "%~dp0*.*" "%DEST_DIR%\" /E /Y /Q > nul

if not exist "%DEST_DIR%\data" mkdir "%DEST_DIR%\data"

:: 3. Instalar librerias Python
echo [3/5] Instalando librerias necesarias...
if defined PY_EXE (
    "%PY_EXE%" -m pip install fastapi uvicorn pydantic gspread google-api-python-client google-auth httpx requests --quiet
)

:: 4. Crear iconos en Escritorio
echo [4/5] Creando acceso directo en el Escritorio...
if exist "%USERPROFILE%\Desktop" (
    copy /Y "%DEST_DIR%\Iniciar_Recepcion_Local.bat" "%USERPROFILE%\Desktop\Abrir_Hostal_Keymar.bat" >nul 2>&1
)
if exist "%USERPROFILE%\OneDrive\Desktop" (
    copy /Y "%DEST_DIR%\Iniciar_Recepcion_Local.bat" "%USERPROFILE%\OneDrive\Desktop\Abrir_Hostal_Keymar.bat" >nul 2>&1
)
powershell -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; foreach ($d in @([Environment]::GetFolderPath('Desktop'), \"$env:USERPROFILE\Desktop\", \"$env:USERPROFILE\OneDrive\Desktop\") | Select-Object -Unique) { if ($d -and (Test-Path $d)) { $s = $ws.CreateShortcut(\"$d\Recepcion Hostal Keymar (Local).lnk\"); $s.TargetPath = '%DEST_DIR%\Iniciar_Recepcion_Local.bat'; $s.WorkingDirectory = '%DEST_DIR%'; $s.Save() } }" >nul 2>&1

echo.
echo ====================================================================
echo   INSTALACION COMPLETADA CON EXITO!
echo   Abriendo el sistema de Recepcion Hostal Keymar...
echo ====================================================================
echo.

cd /d "%DEST_DIR%"
call "%DEST_DIR%\Iniciar_Recepcion_Local.bat"
