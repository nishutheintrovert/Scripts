REM Resets all network sockets
netsh interface ip set dns "Ethernet" dhcp
netsh interface ip set dns "Wi-Fi" dhcp
netsh int ip reset
ipconfig /flushdns
nslookup google.com
pause
