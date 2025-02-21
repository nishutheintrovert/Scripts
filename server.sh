#!/usr/bin/env bash
# cd "$(dirname "$0")"
cd /c/minecraft_server
java -Xmx6G -jar fabric-server-launch.jar nogui
Backup_MC_World.sh
read -p "Press enter to continue"
