Set WshShell = WScript.CreateObject("WScript.Shell")
Set args = WScript.Arguments

For i = 0 To args.Count - 1
    arg = args(i)

    ' Check if the argument is a WAIT command
    If UCase(Left(arg, 5)) = "WAIT:" Then
        ' Extract the number and sleep
        sleepTime = CInt(Mid(arg, 6))
        WScript.Sleep sleepTime
    ElseIf UCase(Left(arg, 6)) = "FOCUS:" Then
        ' Extract the window title and activate it
        windowTitle = Mid(arg, 7)
        WshShell.AppActivate windowTitle
    Else
        ' Otherwise, treat it as a keystroke
        WshShell.SendKeys arg
    End If
Next
