#!/usr/bin/env sh


yay -S syncthing && syncthing; sudo systemctl enable "syncthing@$USER.service" --now
