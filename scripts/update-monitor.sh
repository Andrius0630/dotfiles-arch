#!/usr/bin/env sh

#echo $HOME
#echo $HOSTNAME

if xrandr -q | grep "HDMI-0 connected"; then
	xrandr --setprovideroutputsource modesetting NVIDIA-0
	xrandr --output eDP-1-1 --auto --output HDMI-0 --auto --left-of eDP-1-1 --primary 
	bspc monitor HDMI-0 -d 1 2 3 4
	bspc monitor eDP-1-1 -d 5 6 7 8 9 0
else
	xrandr --setprovideroutputsource modesetting NVIDIA-0
	xrandr --auto
	bspc monitor -d 1 2 3 4 5 6 7 8 9 0
fi

