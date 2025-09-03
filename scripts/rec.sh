#!/usr/bin/env sh

record() {
    "$HOME/dotfiles-arch/scripts/mic-toggle.sh"

    ffmpeg -s 1920x1080 -r 60 -f x11grab -i :0.0 -c:v h264 -f pulse -i default -qp 0 "$HOME/Videos/$(date '+%Y-%m-%d__%a__%H:%M:%S').mp4" &

    echo $! > /tmp/recpid

    notify-send -t 1000 -h string:bgcolor:#2F5249 "Recording started & mic toggled"

    polybar-msg action '#recording-state.hook.0'
}

end() {
    "$HOME/dotfiles-arch/scripts/mic-toggle.sh"

    kill -2 "$(cat /tmp/recpid)" && rm -f /tmp/recpid

    notify-send -t 1000 -h string:bgcolor:#780C28 "Recording ended & mic toggled"

    polybar-msg action '#recording-state.hook.0'
}


([ -f /tmp/recpid ] && end && exit 0) || record
