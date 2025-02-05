#!/usr/bin/env bash
cd "$(dirname "$0")"
java -Xmx2G -jar fabric-server-launch.jar nogui
Backup_MC_World.sh
read -p "Press enter to continue"
