' Enables Vanguard (Needs reboot)
Call CreateObject("Shell.Application").ShellExecute("cmd.exe", "/c ""sc config vgc start= demand & sc config vgk start= system", "", "runas")
