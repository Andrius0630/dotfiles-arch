#!/usr/bin/env sh

step=10
upper_limit=100
lower_limit=0

curr_brightness=$(brightnessctl i | grep % | awk -F '[()]' '{ print $2 }')
curr_brightness=${curr_brightness%\%}

case $1 in
   "inc")
    if [ ${curr_brightness} -ge ${upper_limit} ]; then
        notify-send -u low "Brightness is already maxed out!"
    else
        result=$((curr_brightness+step))
        brightnessctl set +${step}% -q
        notify-send -u low "󰃞 ${result} (+${step})"
    fi
      ;;

   "dec")
    if [ ${curr_brightness} -le ${lower_limit} ]; then
        notify-send -u low "Brightness is already low!"
    else
        result=$((curr_brightness-step))
        brightnessctl set ${step}%- -q
        notify-send -u low "󰃞 ${result} (-${step})"
    fi
      ;;
esac
