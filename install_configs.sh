#!/usr/bin/env bash

shopt -s dotglob
shopt -s nullglob

path="/home/andrey"
configuration_path="${path}/dots/home_dir"

configs=("${configuration_path}/configs/*")
folders=("${configuration_path}/folders/*")
dotfiles=("${configuration_path}/dotfiles/*")

configs_target="/home/andrey/.config/"
mkdir -p "${configs_target}"

for file in "${configs[@]}"; do
  file_name="${file##*/}"
  rm -rf "${configs_target}/${file_name}"
done

if [ ${#configs[@]} -gt 0 ]; then
  ln -sf "${configs[@]}" "${configs_target}"
fi


for file in "${folders[@]}"; do
  file_name="${file##*/}"
  rm -rf "${path}/${file_name}"
done

if [ ${#folders[@]} -gt 0 ]; then
  ln -sf "${folders[@]}" "${path}/"
fi

for file in "${dotfiles[@]}"; do
  file_name="${file##*/}"
  rm -rf "${path}/${file_name}"
done

if [ ${#dotfiles[@]} -gt 0 ]; then
  ln -sf "${dotfiles[@]}" "${path}/"
fi
