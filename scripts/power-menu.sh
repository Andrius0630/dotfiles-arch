#!/usr/bin/env sh

chose=$(echo -e "Shutdown\nReboot\nLock" | rofi -dmenu)


case "$chose" in
    "Shutdown") poweroff
    ;;
    "Reboot") reboot
    ;;
    "Lock") slock
    ;;
    *) exit 1
    ;;
esac

