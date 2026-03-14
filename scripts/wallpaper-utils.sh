#!/usr/bin/env bash
set -euo pipefail

WALL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wallpapers"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/quickshell"
THUMB_CACHE="$CACHE_DIR/wallpaper-thumbs"
JSON_OUT="$CACHE_DIR/wallpapers.json"

mkdir -p "$THUMB_CACHE"
TMP_JSON=$(mktemp)

echo "{ \"wallpapers\": [" > "$TMP_JSON"
first=1
shopt -s nullglob nocaseglob

for file in "$WALL_DIR"/*.{jpg,jpeg,png,mp4,mkv,webm}; do
    filename=$(basename "$file")
    safe_name=$(echo "$filename" | sed 's/\\/\\\\/g; s/"/\\"/g')
    safe_path=$(echo "$file" | sed 's/\\/\\\\/g; s/"/\\"/g')
    thumb="$THUMB_CACHE/${filename}.jpg"
    safe_thumb=$(echo "$thumb" | sed 's/\\/\\\\/g; s/"/\\"/g')

    if [ ! -f "$thumb" ]; then
        ext="${filename##*.}"
        case "${ext,,}" in
            mp4|mkv|webm) nice -n 19 ffmpeg -y -discard nokey -i "$file" -ss 00:00:02 -frames:v 1 -vf "scale=200:-1" "$thumb" >/dev/null 2>&1 ;;
            *) nice -n 19 magick "$file" -thumbnail 200x "$thumb" >/dev/null 2>&1 ;;
        esac
    fi

    [ $first -eq 0 ] && echo "," >> "$TMP_JSON"
    echo -n "  { \"name\": \"$safe_name\", \"path\": \"$safe_path\", \"thumb\": \"$safe_thumb\" }" >> "$TMP_JSON"
    first=0
done

echo -e "\n] }" >> "$TMP_JSON"
mv "$TMP_JSON" "$JSON_OUT"