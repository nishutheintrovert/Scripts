@echo off

:: Request elevation using PowerShell if not already admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set "adapter=Ethernet"

:: Check if the adapter is connected/enabled
netsh interface show interface name="%adapter%" | findstr /C:"Administrative state:" | findstr /C:"Enabled" >nul

if %errorlevel%==0 (
    echo Disabling %adapter%...
    netsh interface set interface name="%adapter%" admin=disabled
) else (
    echo Enabling %adapter%...
    netsh interface set interface name="%adapter%" admin=enabled
)
