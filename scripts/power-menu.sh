#!/usr/bin/env sh

chose=$(printf "Shutdown\nReboot\nLock\nSleep" | rofi -dmenu)


case "$chose" in
    "Shutdown") systemctl poweroff
    ;;
    "Reboot") systemctl reboot
    ;;
    "Sleep") systemctl sleep
    ;;
    "Lock") i3lock
    ;;
    *) exit 1
    ;;
esac

