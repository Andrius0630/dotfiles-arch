#!/usr/bin/env sh

pactl set-source-mute @DEFAULT_SOURCE@ toggle
polybar-msg action '#mic-state.hook.0'
