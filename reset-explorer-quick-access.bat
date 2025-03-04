@echo off
REM Resets Quick Access Folders
cd "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations"
c:
del f01b4d95cf55d32a.automaticDestinations-ms && echo/ && echo File explorer quick access resetted.
pause
