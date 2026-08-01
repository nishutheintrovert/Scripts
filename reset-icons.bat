@echo off
setlocal

:: Check for Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Kill explorer
taskkill /f /im explorer.exe

:: Delete icons cache file
cd /d %userprofile%\AppData\Local\Microsoft\Windows\Explorer
del iconcache*

:: Restarts explorer
start explorer.exe
