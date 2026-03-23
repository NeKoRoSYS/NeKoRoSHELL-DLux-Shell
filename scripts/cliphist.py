#!/usr/bin/env python3
import sys, subprocess, json, os, uuid

FAV_FILE = os.path.expanduser("~/.config/quickshell/clipboard_favorites.json")

def load_favs():
    if os.path.exists(FAV_FILE):
        try:
            with open(FAV_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception: pass
    return []

def save_favs(favs):
    with open(FAV_FILE, "w", encoding="utf-8") as f:
        json.dump(favs, f, indent=2)

def notify(msg):
    subprocess.run(["notify-send", "-u", "low", "-h", "string:x-canonical-private-synchronous:clip", "Clipboard", msg])

if len(sys.argv) < 2: sys.exit(0)
action = sys.argv[1]
arg = sys.argv[2] if len(sys.argv) > 2 else ""

if action == "list-history":
    proc = subprocess.Popen(["cliphist", "list"], stdout=subprocess.PIPE, text=True, errors="replace")
    for line in proc.stdout:
        line = line.strip()
        if not line: continue
        parts = line.split('\t', 1)
        item_id = parts[0]
        preview = parts[1] if len(parts) > 1 else ""
        print(json.dumps({"id": item_id, "preview": preview}))
        sys.stdout.flush()

elif action == "list-favs":
    for f in load_favs():
        print(json.dumps({"id": f.get("id"), "preview": f.get("preview")}))
        sys.stdout.flush()

elif action == "copy-hist":
    subprocess.run(f"cliphist list | awk -v id='{arg}' '$1 == id {{print; exit}}' | cliphist decode | wl-copy", shell=True)
    notify("Copied to clipboard")

elif action == "copy-fav":
    favs = load_favs()
    fav = next((f for f in favs if f.get("id") == arg), None)
    if fav:
        proc = subprocess.Popen(["wl-copy"], stdin=subprocess.PIPE)
        proc.communicate(input=fav["full_text"].encode('utf-8'))
        notify("Favorite Copied 🌟")

elif action == "add-fav":
    proc = subprocess.run(f"cliphist list | awk -v id='{arg}' '$1 == id {{print; exit}}' | cliphist decode", shell=True, capture_output=True)
    full_text = proc.stdout.decode('utf-8', errors='replace')
    if not full_text: sys.exit(0)

    proc2 = subprocess.run(f"cliphist list | awk -v id='{arg}' '$1 == id {{print; exit}}'", shell=True, capture_output=True, text=True, errors='replace')
    preview = proc2.stdout.strip().split('\t', 1)[1] if '\t' in proc2.stdout else ""

    favs = load_favs()
    if not any(f.get("full_text") == full_text for f in favs):
        favs.insert(0, {"id": "fav_" + str(uuid.uuid4())[:8], "preview": preview, "full_text": full_text})
        save_favs(favs)
        notify("Added to Favorites 🌟")
    else:
        notify("Already in Favorites ✨")

elif action == "rm-fav-hist":
    proc = subprocess.run(f"cliphist list | awk -v id='{arg}' '$1 == id {{print; exit}}' | cliphist decode", shell=True, capture_output=True)
    full_text = proc.stdout.decode('utf-8', errors='replace')
    favs = load_favs()
    new_favs = [f for f in favs if f.get("full_text") != full_text]
    if len(favs) != len(new_favs):
        save_favs(new_favs)
        notify("Removed from Favorites ❌")

elif action == "rm-fav":
    favs = load_favs()
    save_favs([f for f in favs if f.get("id") != arg])
    notify("Removed from Favorites ❌")

elif action == "wipe":
    subprocess.run(["cliphist", "wipe"])
    notify("History Cleared 🗑️")