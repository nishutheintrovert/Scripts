@echo off
set /p YourVariableName="Are you sure? : "
if /i "%YourVariableName%"=="Y" (
    ::YourCodeHere
    echo/ && echo We did something.
    timeout 3
) else (
    echo/ && echo We did not do anything, we are leaving :(
    timeout 3
    EXIT
)
