#!/usr/bin/env sh

chose=$(printf "Shutdown\nReboot\nLock\nSleep" | rofi -dmenu)


case "$chose" in
    "Shutdown") systemctl poweroff
    ;;
    "Reboot") systemctl reboot
    ;;
    "Sleep") systemctl sleep
    ;;
    "Lock") $HOME/dotfiles-arch/scripts/i3lock-blur.sh
    ;;
    *) exit 1
    ;;
esac

