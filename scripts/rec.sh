#!/usr/bin/env sh

record() {
    pactl set-source-mute @DEFAULT_SOURCE@ toggle

    ffmpeg -s 1920x1080 -r 60 -f x11grab -i :0.0 -c:v h264 -f pulse -i default -qp 0 "$HOME/Videos/$(date '+%Y-%m-%d__%a__%H:%M:%S').mp4" &

    echo $! > /tmp/recpid

    notify-send -t 1000 -h string:bgcolor:#a3be8c "Recording started & mic toggled"
}

end() {
    pactl set-source-mute @DEFAULT_SOURCE@ toggle

    kill -2 "$(cat /tmp/recpid)" && rm -f /tmp/recpid

    notify-send -t 1000 -h string:bgcolor:#bf616a "Recording ended & mic toggled"
}

([ -f /tmp/recpid ] && end && exit 0) || record
