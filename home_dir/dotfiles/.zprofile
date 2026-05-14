
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
   export XDG_SESSION_TYPE=wayland
   export XDG_CURRENT_DESKTOP=niri
   export ELECTRON_OZONE_PLATFORM_HINT=auto   # Electron apps auto-detect Wayland (VS Code, Discord, etc.)
   export MOZ_ENABLE_WAYLAND=1               # Firefox/librewolf native Wayland
   export QT_QPA_PLATFORM=wayland            # Qt apps (Telegram desktop, etc.)
   export SDL_VIDEODRIVER=wayland            # SDL games/apps
   # exec startx
   exec niri
fi

