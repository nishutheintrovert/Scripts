@echo off
setlocal

:: --- CONFIGURATION ---
set "MSYS_BIN=C:\msys64\msys2.exe"
set "WINDOW_TITLE=MSYS2 MSYS Shell"

:: Check for Maximize argument
if not "%1" == "max" start /MAX cmd /c %0 max & exit/b

echo **************************************************
echo *          MSYS2 EXTERNAL UPDATE TOOL            *
echo **************************************************

:: --- UPDATE SEQUENCE ---

:: Step 1: Update Package Database (-Sy)
call :LaunchAndWait "Refreshing Databases..." "-Sy"

:: Step 2: Core Update (-Syu)
call :LaunchAndWait "Core System Update (Pass 1)..." "-Syu"

:: Step 3: Second Pass (-Syu)
call :LaunchAndWait "Full System Update (Pass 2)..." "-Syu"

:: Step 4: Force Sync (-Syyuu)
:: CHANGED: Replaced '&' with 'and' to fix the crash
call :LaunchAndWait "Force Sync and Conflict Resolution..." "-Syyuu"

echo **************************************************
echo *             ALL UPDATES COMPLETE               *
echo **************************************************
pause
exit /b 0

:: FUNCTION: Launch process and wait for window to close
:LaunchAndWait
set "DESC=%~1"
set "ARGS=%~2 --noconfirm --disable-download-timeout"

echo --------------------------------------------------
echo %DESC%
echo Launching: msys2.exe pacman %~2

:: Launch MSYS2 in its own window
start "" "%MSYS_BIN%" pacman %ARGS%

:: Wait for the window to initialize (avoid race condition)
timeout /t 2 /nobreak >nul

:WaitLoop
:: Check if the specific window title exists
tasklist /v /fi "IMAGENAME eq mintty.exe" | find /i "%WINDOW_TITLE%" >nul
if not errorlevel 1 (
    :: Window is still open, wait 1 second and check again
    timeout /t 1 /nobreak >nul
    goto WaitLoop
)

exit /b
