#!/usr/bin/env sh

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
#killall -q polybar

#while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

# Launch bar1 and bar2
#echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
#polybar bar1 2>&1 | tee -a /tmp/polybar1.log & disown

polybar main &
if xrandr -q | grep 'HDMI-0 connected'; then
    polybar secondary &
fi
#echo "Bars launched..."
