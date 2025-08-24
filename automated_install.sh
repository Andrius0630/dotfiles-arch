#!/usr/bin/env sh

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

yay -S alsa-firmware alsa-utils arc-gtk-theme base-devel brightnessctl blueman bluez bluez-utils bspwm dunst engrampa fastfetch fish flameshot flatpak fuse2 gdb gedit gimp git htop irssi kitty lxappearance mc mpv nbfc-linux ncdu neovim networkmanager nitrogen openfortivpn papirus-icon-theme pavucontrol picom polybar pulseaudio pulseaudio-bluetooth python qbittorrent qutebrowser qview rofi rust shellcheck spotify-launcher sshfs sxhkd telegram-desktop thunar tree ttf-font-awesome ttf-liberation ttf-roboto-mono-nerd vim xclip xorg xorg-xinit xorg-xrandr xorg-setxkbmap xorg-xsetroot xorg-xset zip ly

systemctl enable --now NetworkManager
systemctl enable --now bluetooth.service

chsh -s /usr/bin/fish

yay -Scc

systemctl enable ly
