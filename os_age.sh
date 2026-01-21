#!/usr/bin/env sh

age="$(( ($(date +%s) - $(stat -c %W /)) / 86400 ))"

echo "OS age: $age days"
