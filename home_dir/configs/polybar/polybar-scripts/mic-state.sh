#!/usr/bin/env sh

muted=$(pacmd list-sources|grep -A 15 '* index'|awk '/muted:/{ print $2 }')

if [ "$muted" = "yes" ]; then
    echo " "
else
    echo ""
fi
