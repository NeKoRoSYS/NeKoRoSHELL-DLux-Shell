#!/usr/bin/env bash
set -euo pipefail

WALL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wallpapers"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/quickshell"
THUMB_CACHE="$CACHE_DIR/wallpaper-thumbs"
JSON_OUT="$CACHE_DIR/wallpapers.json"

mkdir -p "$THUMB_CACHE"

TMP_JSON="$JSON_OUT.tmp"

echo "{ \"wallpapers\": [" > "$TMP_JSON"
first=1
shopt -s nullglob nocaseglob
for file in "$WALL_DIR"/*.{jpg,jpeg,png,mp4,mkv,webm}; do
    filename=$(basename "$file")
    ext="${filename##*.}"
    thumb="$THUMB_CACHE/${filename}.jpg"

    if [ ! -f "$thumb" ]; then
        case "${ext,,}" in
            mp4|mkv|webm) nice -n 19 ffmpeg -y -discard nokey -i "$file" -ss 00:00:02 -frames:v 1 -vf "scale=200:-1" "$thumb" >/dev/null 2>&1 & ;;
            png|jpg|jpeg) nice -n 19 magick "$file" -thumbnail 200x "$thumb" >/dev/null 2>&1 & ;;
        esac
    fi

    [ $first -eq 0 ] && echo "," >> "$TMP_JSON"
    echo -n "  { \"name\": \"$filename\", \"path\": \"$file\", \"thumb\": \"$thumb\" }" >> "$TMP_JSON"
    first=0
done
shopt -u nullglob nocaseglob

echo -e "\n] }" >> "$TMP_JSON"

mv "$TMP_JSON" "$JSON_OUT"