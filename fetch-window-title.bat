@echo off
echo *************************************************************************************************************************************
if not "%1" == "max" start /MAX cmd /c %0 max & exit/b
TASKLIST /v /fo list |find /i "window title" |find /v "N/A"
pause
