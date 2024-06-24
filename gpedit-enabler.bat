@echo off
set /p YourVariableName="Are you sure? : "
if /i "%YourVariableName%"=="Y" (
    pushd "%~dp0"
    dir /b %SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientExtensions-Package~3*.mum >List.txt
    dir /b %SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientTools-Package~3*.mum >>List.txt
    for /f %%i in ('findstr /i . List.txt 2^>nul') do dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%i"
    pause
    echo/ && echo We did something.
    timeout 3
) else (
    echo/ && echo We did not do anything, we are leaving :(
    timeout 3
    EXIT
)
