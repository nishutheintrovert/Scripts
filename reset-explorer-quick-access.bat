@echo off
set /p YourVariableName="Are you sure you want to ResetFileExplorerQuickAccess ? : "
if /i "%YourVariableName%"=="Y" (
    cd "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations"
    c:
    del f01b4d95cf55d32a.automaticDestinations-ms && echo/ && echo File explorer quick access resetted.
) else (
    EXIT
)
