#!/usr/bin/env sh

weather=$(curl -s wttr.in/Vilnius\?format="%t\n")

echo $weather #| tr -d '\u00A0'
