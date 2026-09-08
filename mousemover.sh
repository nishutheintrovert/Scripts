#!/usr/bin/env bash

printf '\e[2t'

printf -v output "%(%Y-%m-%d)T" -1

win_desktop_path=$(reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" //v Desktop | awk -F'    ' '/Desktop/{print $4}')
DESKTOP_DIR=$(cygpath "$win_desktop_path")

output_file="$DESKTOP_DIR/$output".fsh

if [ ! -f "$output_file" ]; then
    echo -ne "#!/usr/bin/env bash\n\nprintf '\\\e[2t'\n" >>"$output_file"
fi

echo "" >>"$output_file"
echo "mousemover moveto $(mousemover position)" >>"$output_file"
echo "read -t 0.5" >>"$output_file"
echo "mousemover click" >>"$output_file"
mousemover click
