#!/usr/bin/env bash

sudo tee "/usr/lib/systemd/system-sleep/iwlwifi-reset" << "EOF"
#!/bin/sh
case $1 in
  pre)
    echo "Unloading iwlwifi to prevent crash..."
    modprobe -r iwlmvm
    modprobe -r iwlwifi
    ;;
  post)
    echo "Reloading iwlwifi..."
    modprobe iwlwifi
    modprobe iwlmvm
    ;;
esac
EOF

sudo chmod +x "/usr/lib/systemd/system-sleep/iwlwifi-reset"
