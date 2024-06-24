@echo off

if not "%1" == "max" start /MAX cmd /c %0 max & exit/b

goto update1

:system1
timeout /t 1 /nobreak >nul
tasklist /v | find /i "MSYS2 MSYS Shell" >nul
if not errorlevel 1 (
    goto system1
)

goto update2

:system2
timeout /t 1 /nobreak >nul
tasklist /v | find /i "MSYS2 MSYS Shell" >nul
if not errorlevel 1 (
    goto system2
)

goto update3

:system3
timeout /t 1 /nobreak >nul
tasklist /v | find /i "MSYS2 MSYS Shell" >nul
if not errorlevel 1 (
    goto system3
)

goto update4

:system4
timeout /t 1 /nobreak >nul
tasklist /v | find /i "MSYS2 MSYS Shell" >nul
if not errorlevel 1 (
    goto system4
)

goto update5

:system5
timeout /t 1 /nobreak >nul
tasklist /v | find /i "MSYS2 MSYS Shell" >nul
if not errorlevel 1 (
    goto system5
)

goto update6

:system6
timeout /t 1 /nobreak >nul
tasklist /v | find /i "MSYS2 MSYS Shell" >nul
if not errorlevel 1 (
    goto system6
)

goto update7

:system7
timeout /t 1 /nobreak >nul
tasklist /v | find /i "MSYS2 MSYS Shell" >nul
if not errorlevel 1 (
    goto system7
)

goto update8

:system8
timeout /t 1 /nobreak >nul
tasklist /v | find /i "MSYS2 MSYS Shell" >nul
if not errorlevel 1 (
    goto system8
)

goto last

:update1
echo **************************************************
echo *Updating Core System.                           *
start "" "C:\msys64\msys2.exe" pacman -Su --disable-download-timeout --noconfirm
goto :system1

:update2
echo *Done!                                           *
echo *------------------------------------------------*
echo *Updating Core System.                           *
start "" "C:\msys64\msys2.exe" pacman -Su --disable-download-timeout --noconfirm
goto :system2

:update3
echo *Done!                                           *
echo *------------------------------------------------*
echo *Updating Packages.                              *
start "" "C:\msys64\msys2.exe" pacman -Sy --disable-download-timeout --noconfirm
goto :system3

:update4
echo *Done!                                           *
echo *------------------------------------------------*
echo *Updating Packages.                              *
start "" "C:\msys64\msys2.exe" pacman -Sy --disable-download-timeout --noconfirm
goto :system4

:update5
echo *Done!                                           *
echo *------------------------------------------------*
echo *Updating Packages and Core System.              *
start "" "C:\msys64\msys2.exe" pacman -Syu --disable-download-timeout --noconfirm
goto :system5

:update6
echo *Done!                                           *
echo *------------------------------------------------*
echo *Updating Packages and Core System.              *
start "" "C:\msys64\msys2.exe" pacman -Syu --disable-download-timeout --noconfirm
goto :system6

:update7
echo *Done!                                           *
echo *------------------------------------------------*
echo *Force Sync Packages and allow downgrade/upgrade.*
start "" "C:\msys64\msys2.exe" pacman -Syyuu --disable-download-timeout --disable-download-timeout --noconfirm
goto :system7

:update8
echo *Done!                                           *
echo *------------------------------------------------*
echo *Force Sync Packages and allow downgrade/upgrade.*
start "" "C:\msys64\msys2.exe" pacman -Syyuu --disable-download-timeout --disable-download-timeout --noconfirm
goto :system8

:last
echo *Done!                                           *
echo **************************************************
pause>nul
exit /b 0
