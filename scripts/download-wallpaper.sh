#!/usr/bin/env bash
set -euo pipefail

URL="$1"
WALL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wallpapers"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/quickshell"
THUMB_CACHE="$CACHE_DIR/wallpaper-thumbs"
JSON_OUT="$CACHE_DIR/wallpapers.json"

mkdir -p "$WALL_DIR" "$THUMB_CACHE"

FILENAME=$(basename "$URL" | cut -d? -f1)
[[ -z "$FILENAME" ]] && FILENAME="dl_$(date +%s).jpg"
TARGET="$WALL_DIR/$FILENAME"

curl -sL "$URL" -o "$TARGET"

ext="${FILENAME##*.}"
thumb="$THUMB_CACHE/${FILENAME}.jpg"
case "${ext,,}" in
    mp4|mkv|webm) ffmpeg -y -i "$TARGET" -ss 00:00:01 -frames:v 1 -vf "scale=200:-1" "$thumb" >/dev/null 2>&1 ;;
    *) magick "$TARGET" -thumbnail 200x "$thumb" >/dev/null 2>&1 ;;
esac

bash "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/scripts/wallpaper-utils.sh"

echo "$TARGET"