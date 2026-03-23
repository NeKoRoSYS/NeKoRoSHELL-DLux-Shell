#!/usr/bin/env bash
exec > /tmp/nekoroshell-wallpaper-dl.log 2>&1
set -x 

URL="$1"
WALL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wallpapers"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/nekoroshell"
THUMB_CACHE="$CACHE_DIR/wallpaper-thumbs"

mkdir -p "$WALL_DIR" "$THUMB_CACHE"

FILENAME=$(basename "$URL" | cut -d? -f1)
[[ -z "$FILENAME" ]] && FILENAME="dl_$(date +%s).jpg"
TARGET="$WALL_DIR/$FILENAME"

echo "Downloading: $URL"
curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -sL "$URL" -o "$TARGET" || {
    echo "Curl failed to download!"
    exit 1
}

if grep -qi "<html" "$TARGET"; then
    echo "ERROR: Downloaded an HTML file. The website blocked the request."
    rm "$TARGET"
    exit 1
fi

ext="${FILENAME##*.}"
thumb="$THUMB_CACHE/${FILENAME}.jpg"

echo "Generating thumbnail..."
case "${ext,,}" in
    mp4|mkv|webm) ffmpeg -y -i "$TARGET" -ss 00:00:01 -frames:v 1 -vf "scale=200:-1" "$thumb" >/dev/null 2>&1 || true ;;
    *) magick "$TARGET" -thumbnail 200x "$thumb" >/dev/null 2>&1 || convert "$TARGET" -thumbnail 200x "$thumb" >/dev/null 2>&1 || true ;;
esac

echo "Updating JSON..."
bash "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/scripts/wallpaper-utils.sh" || true

echo "Done! Saved to $TARGET"