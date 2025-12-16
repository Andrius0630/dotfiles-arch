#!/usr/bin/env sh

sudo add-apt-repository ppa:fish-shell/release-4
sudo apt update & sudo apt install fish
chsh -s $(which fish)
