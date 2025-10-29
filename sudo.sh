#!/bin/bash
powershell.exe -ExecutionPolicy Bypass -File "$(dirname "$0")/elevate.ps1" "$1"
