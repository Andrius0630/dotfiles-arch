#!/usr/bin/env sh

PATH=/usr/bin:/bin

REMOTE_HOST="hetzner"
REMOTE_DIR="forgejo/"
REMOTE_QUADLET=".config/containers/systemd/forgejo.container"
BACKUP_ROOT="$HOME/Tmp/backups/backup_forgejo"
MAILTO="kolendarik123@gmail.com"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
TARGET_DIR="$BACKUP_ROOT/$TIMESTAMP/forgejo"
QUADLET_TARGET_DIR="$BACKUP_ROOT/$TIMESTAMP/quadlet"

mkdir -p "$TARGET_DIR" "$QUADLET_TARGET_DIR"

# Back up the Quadlet unit definition first - static file, no need to stop
# the service for it, and if this fails we bail before touching Forgejo.
if ! rsync -az -e ssh "$REMOTE_HOST:$REMOTE_QUADLET" "$QUADLET_TARGET_DIR/"; then
    rm -rf "$BACKUP_ROOT/$TIMESTAMP"
    echo "rsync of Quadlet unit file from $REMOTE_HOST:$REMOTE_QUADLET failed at $TIMESTAMP" | mail -s "Forgejo backup FAILED" "$MAILTO"
    exit 1
fi

if ! ssh "$REMOTE_HOST" "XDG_RUNTIME_DIR=/run/user/1000 systemctl --user stop forgejo"; then
    rm -rf "$BACKUP_ROOT/$TIMESTAMP"
    echo "Could not stop forgejo quadlet on $REMOTE_HOST before backup" | mail -s "Forgejo backup FAILED" "$MAILTO"
    exit 1
fi

rsync -az -e ssh "$REMOTE_HOST:$REMOTE_DIR" "$TARGET_DIR/"
rsync_status=$?
echo "Done: $rsync_status"

if ! ssh "$REMOTE_HOST" "XDG_RUNTIME_DIR=/run/user/1000 systemctl --user start forgejo"; then
    echo "Failed to restart forgejo quadlet on $REMOTE_HOST after backup" | mail -s "Forgejo restart FAILED" "$MAILTO"
fi

if [ "$rsync_status" -ne 0 ]; then
    rm -rf "$BACKUP_ROOT/$TIMESTAMP"
    echo "rsync from $REMOTE_HOST:$REMOTE_DIR failed at $TIMESTAMP" | mail -s "Forgejo backup FAILED" "$MAILTO"
    exit 1
fi

# Pack the backup into one file so copying it to the NAS moves one file
# instead of thousands. Write to .partial first so an interrupted run never
# leaves a truncated archive under the final name.
ARCHIVE="$BACKUP_ROOT/$TIMESTAMP.tar.gz"
if ! tar -czf "$ARCHIVE.partial" -C "$BACKUP_ROOT" "$TIMESTAMP"; then
    rm -f "$ARCHIVE.partial"
    echo "tar of $BACKUP_ROOT/$TIMESTAMP failed, unpacked backup kept" | mail -s "Forgejo backup archive FAILED" "$MAILTO"
    exit 1
fi
mv "$ARCHIVE.partial" "$ARCHIVE"
rm -rf "$BACKUP_ROOT/$TIMESTAMP"
