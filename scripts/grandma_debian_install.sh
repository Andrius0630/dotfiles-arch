#!/usr/bin/env bash

sudo apt install network-manager xorg ratpoison rxvt-unicode ranger sxiv firefox-esr ueberzugpp

cat << "EOF" > ".ratpoisonrc"
# Disable the "Welcome to Ratpoison" message
startup_message off

# Set the prefix to something she won't hit (default is Ctrl+t)
# But we will use "top-level" binds so she doesn't need a prefix.
escape Super_L

# The "Grandma Shortcuts" - Direct access
definekey top F1 exec urxvt -e ranger
definekey top F2 exec firefox-esr
definekey top F3 exec sxiv -t ~/Pictures  # Thumbnail mode for photos
definekey top F4 kill

# Force every window to be fullscreen (Monocle)
alias only only
addhook newwindow only

# Auto-start Ranger on boot
exec urxvt -e ranger
EOF
