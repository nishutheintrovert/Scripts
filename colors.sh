#!/bin/bash

# Function to print color details
print_color_info() {
    local name=$1
    local code=$2
    local hex=$3
    local style=$4

    # Generate ANSI escape sequence
    local ansi="\033[${code}m"

    # Print color information
    printf "${ansi}%-15s %-5s %-10s %-15s %-10s\033[0m\n" "$name" "$code" "$hex" "$ansi" "$style"
}

# Color and style definitions: name, code, hex, style
colors=(
    "Reset" 0 "#000000" "reset"
    "Bold" 1 "#000000" "bold"
    "Underline" 4 "#000000" "underline"
    "Inverse" 7 "#000000" "inverse"
    "black" 30 "#000000" "normal"
    "red" 31 "#FF0000" "normal"
    "green" 32 "#00FF00" "normal"
    "yellow" 33 "#FFFF00" "normal"
    "blue" 34 "#0000FF" "normal"
    "magenta" 35 "#FF00FF" "normal"
    "cyan" 36 "#00FFFF" "normal"
    "white" 37 "#FFFFFF" "normal"
    "brightblack" 90 "#555555" "bright"
    "brightred" 91 "#FF5555" "bright"
    "brightgreen" 92 "#55FF55" "bright"
    "brightyellow" 93 "#FFFF55" "bright"
    "brightblue" 94 "#5555FF" "bright"
    "brightmagenta" 95 "#FF55FF" "bright"
    "brightcyan" 96 "#55FFFF" "bright"
    "brightwhite" 97 "#AAAAAA" "bright"
    "bgblack" 40 "#000000" "background"
    "bgred" 41 "#FF0000" "background"
    "bggreen" 42 "#00FF00" "background"
    "bgyellow" 43 "#FFFF00" "background"
    "bgblue" 44 "#0000FF" "background"
    "bgmagenta" 45 "#FF00FF" "background"
    "bgcyan" 46 "#00FFFF" "background"
    "bgwhite" 47 "#FFFFFF" "background"
    "bgbrightblack" 100 "#555555" "bright background"
    "bgbrightred" 101 "#FF5555" "bright background"
    "bgbrightgreen" 102 "#55FF55" "bright background"
    "bgbrightyellow" 103 "#FFFF55" "bright background"
    "bgbrightblue" 104 "#5555FF" "bright background"
    "bgbrightmagenta" 105 "#FF55FF" "bright background"
    "bgbrightcyan" 106 "#55FFFF" "bright background"
    "bgbrightwhite" 107 "#AAAAAA" "bright background"
)

# Print header
printf "%-15s %-5s %-10s %-15s %-10s\n" "Color Name" "Code" "Hex Value" "ANSI Sequence" "Style"
printf "%-15s %-5s %-10s %-15s %-10s\n" "----------" "----" "---------" "-------------" "-----"

# Loop through colors and print details
for ((i = 0; i < ${#colors[@]}; i += 4)); do
    print_color_info "${colors[i]}" "${colors[i + 1]}" "${colors[i + 2]}" "${colors[i + 3]}"
done

# Color Name      Code  Hex Value  ANSI Sequence   Style
# ----------      ----  ---------  -------------   -----
# Reset           0     #000000    \033[0m         reset
# Bold            1     #000000    \033[1m         bold
# Underline       4     #000000    \033[4m         underline
# Inverse         7     #000000    \033[7m         inverse
# black           30    #000000    \033[30m        normal
# red             31    #FF0000    \033[31m        normal
# green           32    #00FF00    \033[32m        normal
# yellow          33    #FFFF00    \033[33m        normal
# blue            34    #0000FF    \033[34m        normal
# magenta         35    #FF00FF    \033[35m        normal
# cyan            36    #00FFFF    \033[36m        normal
# white           37    #FFFFFF    \033[37m        normal
# brightblack     90    #555555    \033[90m        bright
# brightred       91    #FF5555    \033[91m        bright
# brightgreen     92    #55FF55    \033[92m        bright
# brightyellow    93    #FFFF55    \033[93m        bright
# brightblue      94    #5555FF    \033[94m        bright
# brightmagenta   95    #FF55FF    \033[95m        bright
# brightcyan      96    #55FFFF    \033[96m        bright
# brightwhite     97    #AAAAAA    \033[97m        bright
# bgblack         40    #000000    \033[40m        background
# bgred           41    #FF0000    \033[41m        background
# bggreen         42    #00FF00    \033[42m        background
# bgyellow        43    #FFFF00    \033[43m        background
# bgblue          44    #0000FF    \033[44m        background
# bgmagenta       45    #FF00FF    \033[45m        background
# bgcyan          46    #00FFFF    \033[46m        background
# bgwhite         47    #FFFFFF    \033[47m        background
# bgbrightblack   100   #555555    \033[100m       bright background
# bgbrightred     101   #FF5555    \033[101m       bright background
# bgbrightgreen   102   #55FF55    \033[102m       bright background
# bgbrightyellow  103   #FFFF55    \033[103m       bright background
# bgbrightblue    104   #5555FF    \033[104m       bright background
# bgbrightmagenta 105   #FF55FF    \033[105m       bright background
# bgbrightcyan    106   #55FFFF    \033[106m       bright background
# bgbrightwhite   107   #AAAAAA    \033[107m       bright background
