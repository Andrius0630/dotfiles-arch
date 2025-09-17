#!/usr/bin/env sh
set -eu

# Files
# Put your files in .config/bookmarks/.
BOOKMARKS_FILE="${BOOKMARKS_FILE:-$HOME/.config/bookmarks/bookmarks.txt}"

# Rofi command
ROFI="rofi -dmenu -i -p 'Bookmarks'"

# Browsers
# Choose your browsers accordingly
BROWSER="$(command -v librewolf || true)"

# Ensure files exist
mkdir -p "$(dirname "$BOOKMARKS_FILE")"
[ -f "$BOOKMARKS_FILE" ] || cat >"$BOOKMARKS_FILE" <<'EOF'
"YouTube" https://youtube.com
EOF

emit() {
  awk '!/^\s*#|^\s*$/ { print $0 }' "$1"
}

# Build combined list
choice="$({
  emit "$BOOKMARKS_FILE"
} | sort | eval "$ROFI" || true)"

[ -n "$choice" ] || exit 0


url=$(echo "$choice" | awk '{print $NF}' | sed 's/[][]//g')

# Open with the default browser
if [ -n "$BROWSER" ]; then
  # nohup & disowns the process, allowing the script to exit
  # This is a common pattern for launching GUI apps from scripts.
  nohup "$BROWSER" --new-tab "$url" >/dev/null 2>&1 & exit 0
  #echo "$url"
fi