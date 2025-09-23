#!/usr/bin/env sh

# setup_external <external_monitor> <laptop_monitor>
setup_external() {
	xrandr --setprovideroutputsource modesetting NVIDIA-0
	xrandr --output "$2" --auto --output "$1" --mode 1920x1080 --left-of "$2" --primary 
	bspc monitor "$1" -d 1 2 3 4
	bspc monitor "$2" -d 5 6 7 8 9 0
}

if xrandr -q | grep "HDMI-0 connected"; then
	setup_external "HDMI-0" "eDP-1-1"
elif xrandr -q | grep "HDMI-1 connected"; then
	setup_external "HDMI-1" "eDP-1"
else
	xrandr --setprovideroutputsource modesetting NVIDIA-0
	xrandr --auto
	bspc monitor -d 1 2 3 4 5 6 7 8 9 0
fi

