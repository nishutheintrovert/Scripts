@echo off

:: Main Script
neon moveto 1900x720
timeout 1
neon click
neon scrolldown 5000
timeout 1
neon moveto 2220x1330
timeout 1
neon click
neon moveto 2200x1260
timeout 1
neon click
timeout 3
neon moveto 2510x1215
pause
echo ******************************

set "iterations=10"
for /l %%i in (1, 1, %iterations%) do (
    echo ******************************
    neon moveto 2470x1131
    call :coreClicker
    echo ******************************
    neon moveto 2470x1047
    call :coreClicker
    echo ******************************
    neon moveto 2470x963
    call :coreClicker
    echo ******************************
    neon moveto 2470x879
    call :coreClicker
    echo ******************************
    neon moveto 2470x795
    call :coreClicker
    echo ******************************
    neon moveto 2470x711
    call :coreClicker
    echo ******************************
    neon moveto 2470x627
    call :coreClicker
    echo ******************************
    neon moveto 2470x543
    call :coreClicker
    echo ******************************
    neon moveto 2470x459
    call :coreClicker
    echo ******************************
    neon moveto 2470x375
    call :coreClicker
    echo ******************************
    neon moveto 2465x1215
    neon click
    timeout 5
    echo ******************************
)

goto :eof

:coreClicker
timeout 1
neon click
neon moveto 1620x220
timeout 3
neon click
neon moveto 1710x1360
timeout 1
neon click
timeout 5
exit /b
