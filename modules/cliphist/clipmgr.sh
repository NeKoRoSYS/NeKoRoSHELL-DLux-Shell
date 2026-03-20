# Configuration
THEME="~/.config/quickshell/modules/cliphist/clipboard.rasi"
FAV_FILE="$HOME/.config/quickshell/clipboard_favorites.txt"

# Ensure the favorites file exists
touch "$FAV_FILE"

# Define the Main Menu Options
OPT_1="📋 View Clipboard History"
OPT_2="🌟 View Favorites"
OPT_3="➕ Add to Favorites"
OPT_4="❌ Remove from Favorites"
OPT_5="🗑️ Clear Clipboard History"

# Build the menu and pipe it into Rofi
MENU_LIST=$(printf '%s\n%s\n%s\n%s\n%s' "$OPT_1" "$OPT_2" "$OPT_3" "$OPT_4" "$OPT_5")
CHOICE=$(printf '%s\n' "$MENU_LIST" | rofi -dmenu -p "Menu" -theme "$THEME")

# Route the user's choice
case "$CHOICE" in
    "$OPT_1")
        SELECTED=$(cliphist list | rofi -dmenu -p "History" -theme "$THEME")
        if [ -n "$SELECTED" ]; then
            printf '%s\n' "$SELECTED" | cliphist decode | wl-copy
        fi
        ;;
        
    "$OPT_2")
        if [ -s "$FAV_FILE" ]; then
            SELECTED=$(rofi -dmenu -p "Favorites" -theme "$THEME" < "$FAV_FILE")
            if [ -n "$SELECTED" ]; then
                printf '%s' "$SELECTED" | wl-copy 
                notify-send -u low -h string:x-canonical-private-synchronous:clip "Clipboard" "Favorite Copied"
            fi
        else
            notify-send -u low -h string:x-canonical-private-synchronous:clip "Clipboard" "No favorites saved yet!"
        fi
        ;;
        
    "$OPT_3")
        SELECTED=$(cliphist list | rofi -dmenu -p "Save Fav" -theme "$THEME")
        if [ -n "$SELECTED" ]; then
            # echo "$(...)" ensures a newline is always added at the end
            echo "$(printf '%s\n' "$SELECTED" | cliphist decode)" >> "$FAV_FILE"
            notify-send -u low -h string:x-canonical-private-synchronous:clip "Clipboard" "Added to Favorites 🌟"
        fi
        ;;

    "$OPT_4")
        if [ -s "$FAV_FILE" ]; then
            SELECTED=$(rofi -dmenu -p "Delete Fav" -theme "$THEME" < "$FAV_FILE")
            if [ -n "$SELECTED" ]; then
                awk -v target="$SELECTED" '$0 == target && !done {done=1; next} 1' "$FAV_FILE" > "${FAV_FILE}.tmp"
                mv "${FAV_FILE}.tmp" "$FAV_FILE"
                notify-send -u low -h string:x-canonical-private-synchronous:clip "Clipboard" "Removed from Favorites ❌"
            fi
        else
            notify-send -u low -h string:x-canonical-private-synchronous:clip "Clipboard" "No favorites to remove!"
        fi
        ;;
        
    "$OPT_5")
        cliphist wipe
        notify-send -u low -h string:x-canonical-private-synchronous:clip "Clipboard" "History Cleared 🗑️"
        ;;
esac