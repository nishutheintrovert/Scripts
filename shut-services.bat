@echo off
echo ************************************************
Echo Run As Administrator
echo ************************************************
net user guest /active:no
net.exe stop "Windows Search"
sc stop "wsearch"
sc stop "wsearch" & sc config "wsearch" start=disabled
sc stop "diagtrack" & sc config "diagtrack" start=disabled
sc stop "mapsbroker" & sc config "mapsbroker" start=disabled
echo ************************************************
Echo Run As Administrator
echo ************************************************
pause
