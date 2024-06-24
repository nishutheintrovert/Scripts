@echo off
set "FolderPath=%~dp0"  REM Set FolderPath to the directory of the batch script

shfmt -l -w -i=4 -ci %FolderPath%
pause
