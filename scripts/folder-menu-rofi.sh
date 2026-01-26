#!/usr/bin/env bash

folder=$(echo "home tmp downloads dotfiles-arch documents pictures videos sync mnt vu trash" | tr " " "\n" | rofi -dmenu)


case "$folder" in
    "home")
        thunar "$HOME"
    ;;
    "tmp")
        thunar "$HOME/Tmp"
    ;;
    "downloads")
        thunar "$HOME/Downloads"
    ;;
    "documents")
        thunar "$HOME/Documents"
    ;;
    "pictures")
        thunar "$HOME/Pictures"
    ;;
    "videos")
        thunar "$HOME/Videos"
    ;;
    "sync")
        thunar "$HOME/Sync"
    ;;
    "trash")
        thunar "trash:///"
    ;;
    "mnt")
        thunar "/mnt/"
    ;;
    "dotfiles-arch")
       thunar "$HOME/dotfiles-arch" 
    ;;
    "vu")
       thunar "$HOME/vu" 
    ;;
    *) exit 1
    ;;
esac

