@echo off
echo/
echo Task killer example :
echo taskkill /F /FI "WINDOWTITLE eq Aimlab*" /T
echo taskkill /F /FI "WINDOWTITLE eq Steam*" /T
echo taskkill /F /Fi "WINDOWTITLE eq steamwebhelper.exe*" /T
echo taskkill /F /FI "WINDOWTITLE eq Steam Big Picture Mode*" /T
echo taskkill /F /Im steam.exe /T
echo taskkill /F /FI "WINDOWTITLE eq Riot Client Main*" /T
echo taskkill /F /Im "VALORANT-Win64-Shipping.exe" /T
echo taskkill /F /Im VALORANT.exe /T
**********************************************************************************
pause
