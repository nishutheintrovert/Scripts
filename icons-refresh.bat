@echo off
echo Run AS ADMIN
set /p YourVariableName="Are you sure? : "
if /i "%YourVariableName%"=="Y" (
    taskkill /f /im explorer.exe
    cd /d %userprofile%\AppData\Local
    del IconCache.db /a
    start explorer.exe
    echo/ && echo We did something.
    timeout 3
) else (
    echo/ && echo We did not do anything, we are leaving :(
    timeout 3
    EXIT
)
