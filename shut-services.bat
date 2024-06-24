@echo off
set /p YourVariableName="Are you sure? : "
if /i "%YourVariableName%"=="Y" (
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
    timeout 3
) else (
    echo/ && echo We did not do anything, we are leaving :(
    timeout 3
    EXIT
)
