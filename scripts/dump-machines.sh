#!/usr/bin/env bash

DATE=$(date +%Y-%m-%d_%H-%M-%S)
TAR='tar czf - --one-file-system --exclude=/dev --exclude=/run --exclude=/swap.img /'
# Host key checking off
SSH_OPTS="-o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
MAX_JOBS=4   # max dumps running at once

HOSTS=(
    "10.0.10.213"
)

dump_one() {
  local entry=$1
  local outfile="${entry}_${DATE}.tar.gz"
  if ssh $SSH_OPTS root@"$entry" "$TAR" > "$outfile"; then
    if tar -tzf "$outfile" >/dev/null 2>&1; then
      echo "[OK]      $entry -> $outfile ($(du -sh "$outfile" | cut -f1))"
    else
      echo "[CORRUPT] $entry -> $outfile removed"
      rm -f "$outfile"
    fi
  else
    echo "[FAIL]    $entry"
    rm -f "$outfile"
  fi
}

echo "Starting backups - up to $MAX_JOBS at a time ($(date))"
echo "----------------------------------------------"

for entry in "${HOSTS[@]}"; do
  dump_one "$entry" &
  # Hold at MAX_JOBS running dumps.
  while [ "$(jobs -rp | wc -l)" -ge "$MAX_JOBS" ]; do
    wait -n 2>/dev/null || sleep 1
  done
done

wait   # let the last batch finish

echo "----------------------------------------------"
echo "Finished ($(date))"
