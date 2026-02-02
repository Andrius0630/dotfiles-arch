#!/usr/bin/env bash

echo "ATTENTION: Ensure your \"/etc/apt/sources.list\" includes \"main contrib non-free non-free-firmware\""

# necessities
sudo apt update && sudo apt install -y git wget curl build-essential

# dotfiles
git clone https://github.com/Andrius0630/dotfiles-arch.git

# additional packages
sudo apt install -y alsa-firmware alsa-utils arc-gtk-theme base-devel blueman bluez bluez-utils brightnessctl dunst engrampa fastfetch fdfind ffmpegthumbnailer ffmpegthumbnailer flameshot fonts-font-awesome fonts-liberation fonts-roboto-mono-nerd fzf gedit gvfs-afc gvfs-gphoto2 gvfs-mtp gvfs-smb htop i3lock ifuse jdk-openjdk kimageformats kitty krita libgepub libgsf libimobiledevice libraw librewolf localsend lxappearance mpv ncdu neovim network-manager nitrogen openfortivpn papirus-icon-theme pavucontrol perl-archive-zip perl-image-exiftool picom polybar poppler-glib pulseaudio pulseaudio-bluetooth python3 qbittorrent qview raw-thumbnailer rofi rsync rustup samba shellcheck spotify-launcher sshfs telegram-desktop thunar thunar-archive-plugin thunar-shares-plugin thunar-volman tmux tree tumbler unrar usbmuxd xclip xorg xorg-setxkbmap xorg-xinit xorg-xrandr xorg-xset xorg-xsetroot zip zsh

# services
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth.service

# magic
mkdir ~/Downloads ~/Videos ~/Documents
sudo cp ~/dotfiles-arch/logind.conf /etc/systemd/logind.conf
xfconf-query --channel thunar --property /misc-exec-shell-scripts-by-default --create --type bool --set true

# zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete ~/.oh-my-zsh/custom/plugins/zsh-autocomplete

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup default stable && rustup target add wasm32-unknown-unknown

# change shell
chsh -s /usr/bin/zsh
