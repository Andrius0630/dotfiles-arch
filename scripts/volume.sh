#!/usr/bin/env sh

step=10
upper_limit=150
lower_limit=$step


right_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '/Volume:/{ print $12 }' | sed 's/%//g')


case $1 in
   "inc")
    if [ ${right_volume} -ge ${upper_limit} ]; then
        notify-send -u low "Volume is already maxed out!"
    else
        result=$((right_volume+step))
        pactl set-sink-volume @DEFAULT_SINK@ +${step}%
        notify-send -u low "  ${result} (+${step})"
    fi
      ;;

   "dec")
    if [ ${right_volume} -le ${lower_limit} ]; then
        notify-send -u low "Volume is already low!"
    else
        result=$((right_volume-step))
        pactl set-sink-volume @DEFAULT_SINK@ -${step}%
        notify-send -u low "  ${result} (-${step})"
    fi
      ;;
esac
