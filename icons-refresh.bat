@echo off
REM Resets Icons
echo Run AS ADMIN
taskkill /f /im explorer.exe
cd /d %userprofile%\AppData\Local
del IconCache.db /a
start explorer.exe
pause
