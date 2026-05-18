#!/bin/bash
DEV=$(ls /sys/class/backlight/ | head -1)
MAX=$(cat /sys/class/backlight/$DEV/max_brightness)
echo $(( MAX * $1 / 100 )) | sudo tee /sys/class/backlight/$DEV/brightness > /dev/null
