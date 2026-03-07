@echo off
REM Wrapper batch file to run PowerShell script with drag-and-drop support

REM Check if any files were dropped
if "%~1"=="" (
    echo No files provided!
    echo.
    echo Usage: Drag and drop image files onto this batch file
    echo.
    pause
    exit /b 1
)

REM Run PowerShell script with all arguments
powershell.exe -ExecutionPolicy Bypass -File "%~dp0optimize-images.ps1" %*
