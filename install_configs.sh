#!/usr/bin/env sh

configuration_path="${HOME}/dots/home_dir"
target_configs="${HOME}/.config"

echo "Creating \".config\" folder in \"${HOME}\"..."
mkdir -p "${target_configs}"

# configs ---------------------------

echo "Making symlinks in \".config\" to the actual config files ..."
echo "Found config folders:"
for file in "${configuration_path}"/configs/*
do
    if [ -e "$file" ] || [ -L "$file" ]; then
        file_name="${file##*/}"
        echo "  ${file_name}"

        rm -r "${target_configs:?}"/"${file_name}" 2> /dev/null
        ln -sf "$file" "${target_configs:?}"/
    fi
done

for file in "${configuration_path}"/configs/.*
do
    if [ -e "$file" ] || [ -L "$file" ]; then
        file_name="${file##*/}"
        echo "  ${file_name}"

        rm -r "${target_configs:?}"/"${file_name}" 2> /dev/null
        ln -sf "$file" "${target_configs:?}"/
    fi
done


# dotfiles ---------------------------

echo "Making symlinks in \"${HOME}\" to the actual dotfiles..."
echo "Found dotfiles for the \"${HOME}\" folder:"
for file in "${configuration_path}"/dotfiles/*
do
    if [ -e "$file" ] || [ -L "$file" ]; then
        file_name="${file##*/}"
        echo "  ${file_name}"

        rm -r "${HOME:?}"/"${file_name}" 2> /dev/null
        ln -sf "$file" "${HOME:?}"/
    fi
done


for file in "${configuration_path}"/dotfiles/.*
do
    if [ -e "$file" ] || [ -L "$file" ]; then
        file_name="${file##*/}"
        echo "  ${file_name}"

        rm -r "${HOME:?}"/"${file_name}" 2> /dev/null
        ln -sf "$file" "${HOME:?}"/
    fi
done

# wallpapers ---------------------------

wallpaper_folder="wallpaper"

echo "Creating \"Pictures\" folder in \"${HOME}\"..."
echo "Creating symlinks for \"${wallpaper_folder}\" folder..."
mkdir -p "${HOME:?}"/Pictures/

rm -r "${HOME:?}"/Pictures/"${wallpaper_folder}" 2> /dev/null
ln -sf "${configuration_path}"/folders/"${wallpaper_folder}" "${HOME:?}"/Pictures/

echo ""
echo "Done! Your user's home folder is now configured"