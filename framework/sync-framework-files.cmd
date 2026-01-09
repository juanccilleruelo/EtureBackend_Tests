@echo off
REM Script para sincronizar archivos del framework mediante hardlinks
REM Ejecuta el script PowerShell con bypass de la politica de ejecucion

cd /d "%~dp0"
PowerShell -ExecutionPolicy Bypass -File ".\sync-framework-files.ps1"

if errorlevel 1 (
    echo.
    echo ERROR: El script no se ejecuto correctamente.
    pause
    exit /b 1
)

echo.
echo Presione cualquier tecla para cerrar...
pause >nul
