#!/bin/sh

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

xrandr --setprovideroutputsource modesetting NVIDIA-0
if xrandr -q | grep 'HDMI-0 disconnected';
  then
    xrandr --output eDP-1-1 --mode 1920x1080 --rate 60.02
fi
#xrandr --auto


xsetroot -cursor_name left_ptr
nitrogen --restore
picom --daemon --config ~/.config/picom/picom.conf
#polybar &
xset r rate 250 30
exec bspwm
#exec dwm
exec --no-start-up dunst
