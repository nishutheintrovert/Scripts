// 2>nul||@goto :batch
/*
:batch
@echo off
pause

::delete old file
del %~n0.exe %*
setlocal

:: find csc.exe
set "csc="
for /r "%SystemRoot%\Microsoft.NET\Framework\" %%# in ("*csc.exe") do  set "csc=%%#"

if not exist "%csc%" (
   echo no .net framework installed
   exit /b 10
)

if not exist "%~n0.exe" (
   call %csc% /nologo /warn:0 /out:"%~n0.exe" "%~dpsfnx0" || (
      exit /b %errorlevel%
   )
)
:: run the exe file no need though %~n0.exe %*
endlocal & exit /b %errorlevel%

*/

// C# code here
