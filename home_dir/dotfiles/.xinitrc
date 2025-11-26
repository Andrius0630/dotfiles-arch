#!/usr/bin/env sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources

fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"

fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi


$HOME/dotfiles-arch/scripts/update-monitor.sh

xset r rate 250 30
setsid -f dunst
setsid -f flameshot
xsetroot -cursor_name left_ptr
xset r rate 250 30
nitrogen --restore
#picom --daemon --config ~/.config/picom/picom.conf
xset r rate 250 30
setxkbmap -layout us,ru,lt -option "grp:alt_shift_toggle"
#polybar &
exec bspwm
#i3
#exec dwm
