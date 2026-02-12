#!/usr/bin/env sh

sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && yay -S alsa-firmware alsa-utils arc-gtk-theme base-devel brightnessctl blueman bluez bluez-utils bspwm dunst engrampa fastfetch zsh flameshot l3afpad gimp git htop kitty librewolf-bin localsend-bin lxappearance i3lock mpv ncdu neovim networkmanager nitrogen openfortivpn papirus-icon-theme pavucontrol picom polybar pulseaudio pulseaudio-bluetooth python qbittorrent qutebrowser qview rofi reflector obsidian rustup shellcheck spotify-launcher sshfs sxhkd telegram-desktop thunar tree ttf-font-awesome ttf-liberation ttf-roboto-mono-nerd vim visual-studio-code-bin xclip xorg xorg-xinit xorg-xrandr xorg-setxkbmap xorg-xsetroot xorg-xset zip ly tumbler ffmpegthumbnailer thunar-volman thunar-archive-plugin jdk-openjdk libimobiledevice usbmuxd ifuse gvfs-smb gvfs-mtp gvfs-gphoto2 gvfs-afc kimageformats libraw perl-image-exiftool perl-archive-zip rsync tumbler libgepub libgsf poppler-glib ffmpegthumbnailer libraw samba thunar-shares-plugin gvfs-smb fzf tmux unrar fd

sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth.service
chsh -s /usr/bin/zsh
sudo systemctl enable ly@tty1.service
mkdir ~/Downloads ~/Videos ~/Documents ~/Sync ~/vu ~/Tmp
xfconf-query --channel thunar --property /misc-exec-shell-scripts-by-default --create --type bool --set true
rustup default stable && rustup target add wasm32-unknown-unknown && sudo cp ~/dotfiles-arch/logind.conf /etc/systemd/logind.conf && yay -S raw-thumbnailer && yay -Scc

# zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete ~/.oh-my-zsh/custom/plugins/zsh-autocomplete
