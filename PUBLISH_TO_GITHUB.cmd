@echo off
setlocal
title Publish Doosan Modules to GitHub
cd /d "%~dp0"

echo Starting the Doosan Modules GitHub publisher...
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish-to-github.ps1"
set "PUBLISH_EXIT=%ERRORLEVEL%"

echo.
if not "%PUBLISH_EXIT%"=="0" (
    echo Publishing did not finish. Read the message above for the reason.
) else (
    echo Publishing finished successfully.
)

echo.
pause
exit /b %PUBLISH_EXIT%
