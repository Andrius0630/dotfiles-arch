#!/usr/bin/env bash

yay -S --needed nvidia nvidia-hook cuda


# In "/etc/default/grub"
#     Add nvidia-drm.modeset=1 to the GRUB_CMDLINE_LINUX_DEFAULT line.
#     sudo grub-mkconfig -o /boot/grub/grub.cfg
