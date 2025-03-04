@echo off
set "FolderPath=%~dp0"  REM Set FolderPath to the directory of the batch script

for %%X in ("%FolderPath%\*.txt" "%FolderPath%\*.reg" "%FolderPath%\*.bat") do (
  start /max notepad "%%X" || start "" "%%X"
)
EXIT
