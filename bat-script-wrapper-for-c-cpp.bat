// 2>nul||@goto :batch
/*
:batch
@echo off
pause

::delete old file
del %~n0.exe %*
setlocal

:: Check if gcc is installed
where gcc >nul 2>&1
if errorlevel 1 (
    echo gcc is not installed or not in your PATH.
    endlocal & exit /b 1
)

if not exist "%~n0.exe" (
   gcc -x c "%~dpsfnx0" -o "%~n0.exe"  || (
    ::call g++ for cpp compilation
    exit /b %errorlevel%
   )
)
:: run the exe file no need though %~n0.exe %*
endlocal & exit /b %errorlevel%

*/

// C/Cpp code here
