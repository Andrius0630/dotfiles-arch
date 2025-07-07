#!/usr/bin/env sh

weather=$(curl -s wttr.in/Vilnius\?format="%c%t\n")

echo $weather  | tr -d '\u00A0'
