#!/usr/bin/env sh

PATH=/bin:/usr/bin:/usr/local/bin

BACKUP_DIR="$HOME/Tmp/backups/librewolf-backup"
mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")


if [ -d "$HOME/.config/librewolf/librewolf" ]; then
    BROWSER_DIR="$HOME/.config/librewolf/librewolf"
elif [ -d "$HOME/.librewolf" ]; then
    BROWSER_DIR="$HOME/.librewolf"
else
    echo "Error: No standard LibreWolf directory found." >&2
    exit 1
fi

for profile_path in "$BROWSER_DIR"/*; do
    [ -e "$profile_path" ] || continue

    if [ -d "$profile_path" ] && [ -d "$profile_path/sessionstore-backups" ]; then
        profile_name=$(basename "$profile_path")
        profile_backup_dir="$BACKUP_DIR/$profile_name"

        target_backup_dir="$profile_backup_dir/$TIMESTAMP"
        mkdir -p "$target_backup_dir"

        active_file="$profile_path/sessionstore-backups/recovery.jsonlz4"
        closed_file="$profile_path/sessionstore.jsonlz4"

        copied=0

        if [ -f "$active_file" ]; then
            cp "$active_file" "$target_backup_dir/recovery.jsonlz4"
            copied=1
        fi

        if [ -f "$closed_file" ]; then
            cp "$closed_file" "$target_backup_dir/sessionstore.jsonlz4"
            copied=1
        fi

        if [ "$copied" -eq 0 ]; then
            rmdir "$target_backup_dir" 2>/dev/null
        fi

        cutoff=$(date -d '-7 days' +"%Y-%m-%d_%H-%M-%S")
        for old_backup in "$profile_backup_dir"/*/; do
            [ -d "$old_backup" ] || continue
            old_name=$(basename "$old_backup")
            case "$old_name" in
                20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]_*) ;;
                *) continue ;;
            esac
            if [ "$old_name" \< "$cutoff" ]; then
                rm -rf "$old_backup"
            fi
        done
    fi
done
