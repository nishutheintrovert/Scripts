param([string]$Script)
# Start-Process "C:\Program Files\Git\bin\bash.exe" -ArgumentList "--login", "-i", $Script -Verb RunAs
Start-Process "C:\Program Files\Git\git-bash.exe" -ArgumentList $Script -Verb RunAs
