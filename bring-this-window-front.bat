@echo off

title thisWindow
echo WScript.CreateObject("WScript.Shell").AppActivate(WScript.Arguments.Item(0))>%tmp%\switch.vbs
timeout 3
%tmp%\switch.vbs thisWindow
timeout 2
