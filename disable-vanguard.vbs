' Disable and kill Vanguard
Call CreateObject("Shell.Application").ShellExecute("cmd.exe", "/c ""sc config vgc start= disabled & sc config vgk start= disabled & net stop vgc & net stop vgk & taskkill /IM vgtray.exe""", "", "runas")
