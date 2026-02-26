#!/usr/bin/env bash

echo "ATTENTION: Ensure your \"/etc/apt/sources.list\" includes \"main contrib non-free non-free-firmware\""

# necessities
sudo apt update && sudo apt install -y git wget curl build-essential

# additional packages
sudo apt install -y alsa-utils arc-theme blueman bluez brightnessctl dunst engrampa fastfetch fd-find ffmpegthumbnailer flameshot fonts-font-awesome fonts-liberation fzf l3afpad gvfs gvfs-backends htop i3lock gvfs-fuse kitty krita lxappearance mpv ncdu network-manager nitrogen openfortivpn papirus-icon-theme pavucontrol picom polybar pulseaudio python3 qbittorrent rofi rsync rustup samba shellcheck sshfs thunar thunar-archive-plugin thunar-volman tmux tree tumbler unrar usbmuxd xclip xorg zip zsh ripgrep emacs cmake libtool-bin clang-format pandoc shfmt i3 psmisc extrepo libpam0g-dev libxcb-xkb-dev clangd npm nodejs yt-dlp nsxiv r-base r-base-dev network-manager-openvpn network-manager-openconnect network-manager-strongswan network-manager-l2tp network-manager-applet network-manager-openconncet-gnome scrot imagemagick autorandr jq resolvconf

# libreworlf
sudo extrepo enable librewolf && sudo extrepo update librewolf && sudo apt update && sudo apt install librewolf -y

# neovim
sudo apt-get install ninja-build gettext cmake curl build-essential git
git clone https://github.com/neovim/neovim
cd neovim
git checkout stable
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install

# services
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth.service

# magic
mkdir ~/Downloads ~/Videos ~/Documents ~/Sync ~/vu ~/Tmp
sudo cp ~/dotfiles-arch/logind.conf /etc/systemd/logind.conf
xfconf-query --channel thunar --property /misc-exec-shell-scripts-by-default --create --type bool --set true

# zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete ~/.oh-my-zsh/custom/plugins/zsh-autocomplete

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup default stable && rustup target add wasm32-unknown-unknown && rustup component add rust-analyzer rust-src clippy-preview

# change shell
chsh -s /usr/bin/zsh

# nerd fonts
mkdir -p ~/.local/share/fonts
curl -fLo "SymbolsNerdFont.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip
unzip SymbolsNerdFont.zip -d ~/.local/share/fonts
fc-cache -f -v
rm SymbolsNerdFont.zip

mkdir -p ~/.local/share/fonts
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/RobotoMono.tar.xz
tar -xvf RobotoMono.tar.xz -C ~/.local/share/fonts
fc-cache -f -v
rm RobotoMono.tar.xz

# spotify
curl -sS https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

sudo apt update && sudo apt install spotify-client

cat << "EOF" > "~/.local/share/applications/spotify.desktop"
[Desktop Entry]
Name=Spotify
GenericName=Music Player
Comment=Listen to music using Spotify
Icon=spotify-client
Exec=spotify %U
Terminal=false
Type=Application
Categories=Audio;Music;Player;AudioVideo;
MimeType=x-scheme-handler/spotify;
EOF

# office
## Add GPG key
mkdir -p -m 700 ~/.gnupg
gpg --no-default-keyring --keyring gnupg-ring:/tmp/onlyoffice.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CB2DE8E5
chmod 644 /tmp/onlyoffice.gpg
sudo chown root:root /tmp/onlyoffice.gpg
sudo mv /tmp/onlyoffice.gpg /usr/share/keyrings/onlyoffice.gpg

## Add desktop editors repository
echo 'deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main' | sudo tee -a /etc/apt/sources.list.d/onlyoffice.list

## Update repos and install package
sudo apt update && sudo apt install onlyoffice-desktopeditors


# docker
## Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

## Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER # reboot is needed
