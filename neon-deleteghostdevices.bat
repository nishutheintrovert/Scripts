@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

FOR /f "tokens=* delims=" %%A in ('neon position') do set "position=%%A"
neon click
neon moveto 233x59
timeout 1
neon click
neon moveto 1311x783
timeout 1
neon click
neon moveto !position!
timeout 1
neon scrolldown 5000
exit
