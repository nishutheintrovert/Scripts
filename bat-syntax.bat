exit

::Close Image Name msedge.exe
taskkill /F /Im msedge.exe

::Close windowtitle named Riot Client Main and all its child processes using /F for force, /FI for filter, /T for selecting all child processes
taskkill /F /FI "WINDOWTITLE eq Riot Client Main*" /T

::Find task's window title
TASKLIST /v /fo list |find /i "window title" |find /v "N/A"

::Hides system message if put at the end of any command
{COMMAND}{SPACE}>nul 2>&1

::Ask input from user via prompt TextOutput and save it in VariableName
set /p VariableName="TextOutput"

::Use VariableName
%VariableName%

::Maximize batch file itself by running it twice
if not "%1" == "max" start /MAX cmd /c %0 max & exit/b

::Minimize batch file itself by running it twice
if not "%1" == "min" start /MIN cmd /c %0 min & exit/b

::Loop until starting position 1, incremented by 1, reaches 10 and prints i
@echo off
set iterations=10
for /l %%i in (1,1,%iterations%) do (
    echo %%i
)
::Copy text/command to clipboard
Text/Command  | clip

::Bring window front
echo WScript.CreateObject("WScript.Shell").AppActivate(WScript.Arguments.Item(0))>%tmp%\switch.vbs

echo 'call this script and then give argument in double quotation markes>>%tmp%\switch.vbs
echo 'eg. switch.vbs "Notepad">>%tmp%\switch.vbs
echo 'you can use variables to give arguments too like "%VariableName%">>%tmp%\switch.vbs

%tmp%\switch.vbs "FileName"

::Starts CMD, create new folder from userInput, open new folder in new window
set /p FolderName="Enter Folder Name : "
mkDir "%FolderName%" && start "" "%FolderName%"

::Starts CMD, create new file from userInput, open new file in new max notepad window
set /p FileName="Enter FileName.Extension : "
ECHO off> "%FileName%" && start "" /max notepad "%FileName%"
