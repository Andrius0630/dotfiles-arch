#!/usr/bin/env sh

sudo reflector --latest 20 --p https --sort rate --save /etc/pacman.d/mirrorlist
