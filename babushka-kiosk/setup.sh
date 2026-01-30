#!/usr/bin/env bash

if [ "$EUID" -eq 0 ]; then
  echo "Error: Please do NOT run this script as root or with sudo."
  exit 1
fi

user="$USER"

sudo apt update && sudo apt install -y xorg i3 i3status libuser neovim git curl ranger nitrogen openssh-server rofi thunar ranger firefox-esr onboard dunst flameshot

sudo mkdir -p "/etc/systemd/system/getty@tty1.service.d"

cat << EOF | sudo tee "/etc/systemd/system/getty@tty1.service.d/autologin.conf"
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $user --noclear %I $TERM
EOF

cd "$HOME/dotfiles-arch/X11_extra/" || (echo "ERROR: cd failed" && exit 1)
sudo cp 00-keyboard.conf 30-touchpad.conf 50-mouse-acceleration.conf /etc/X11/xorg.conf.d/

cat << EOF | tee "$HOME/.bash_profile"
#!/usr/bin/env bash

if [[ -z \$DISPLAY ]] && [[ \$(tty) = /dev/tty1 ]]; then
  exec startx
fi

EOF

cat << EOF | tee "$HOME/.xinitrc"
#!/usr/bin/env sh

xset r rate 250 30
setsid -f dunst
setsid -f flameshot
xsetroot -cursor_name left_ptr
xset r rate 250 30
nitrogen --restore
#picom --daemon --config ~/.config/picom/picom.conf
xset r rate 250 30
setxkbmap -layout us,ru,lt -option "grp:alt_shift_toggle"
#polybar &
exec i3
EOF

configuration_path="${HOME}/dotfiles-arch/babushka-kiosk"
target_configs="${HOME}/.config"
echo "Making symlinks in \".config\" to the actual config files ..."
echo "Found config folders:"
for file in "${configuration_path}"/.config/*
do
    if [ -e "$file" ] || [ -L "$file" ]; then
        file_name="${file##*/}"
        echo "  ${file_name}"

        rm -r "${target_configs:?}"/"${file_name}" 2> /dev/null
        ln -sf "$file" "${target_configs:?}"/
    fi
done

for file in "${configuration_path}"/.config/.*
do
    if [ -e "$file" ] || [ -L "$file" ]; then
        file_name="${file##*/}"
        echo "  ${file_name}"

        rm -r "${target_configs:?}"/"${file_name}" 2> /dev/null
        ln -sf "$file" "${target_configs:?}"/
    fi
done


