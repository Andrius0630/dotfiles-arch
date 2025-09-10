#!/usr/bin/env sh

notify-send -t 1000 -h string:bgcolor:#2F5249 "Webcam viewer launched!"
mpv av://v4l2:/dev/video0 --profile=low-latency --untimed
