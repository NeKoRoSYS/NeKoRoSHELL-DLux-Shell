#!/usr/bin/env python3
import os, json
from pathlib import Path

apps = []
dirs = [
    os.path.expanduser("~/.local/share/applications"),
    "/usr/share/applications",
    "/var/lib/flatpak/exports/share/applications"
]

for d in dirs:
    if not os.path.exists(d): continue
    for path in Path(d).rglob("*.desktop"):
        try:
            # Use ignore to prevent crashing on weird encodings
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                lines = f.readlines()
            
            name = ""
            icon = ""
            exec_cmd = ""
            nodisplay = False
            in_desktop_entry = False
            
            for line in lines:
                line = line.strip()
                if line == "[Desktop Entry]":
                    in_desktop_entry = True
                    continue
                elif line.startswith("["):
                    in_desktop_entry = False
                    continue
                    
                if in_desktop_entry:
                    if line.startswith("Name=") and not name:
                        name = line[5:]
                    elif line.startswith("Icon=") and not icon:
                        icon = line[5:]
                    elif line.startswith("Exec=") and not exec_cmd:
                        exec_cmd = line[5:]
                    elif line.startswith("NoDisplay=") and line[10:].lower() == "true":
                        nodisplay = True
                        
            if name and exec_cmd and not nodisplay:
                exec_cmd = exec_cmd.split("%")[0].strip()
                apps.append({"name": name, "icon": icon, "exec": exec_cmd})
        except:
            pass

# Deduplicate by name and sort alphabetically
seen = set()
unique_apps = []
for app in apps:
    if app["name"] not in seen:
        seen.add(app["name"])
        unique_apps.append(app)

unique_apps.sort(key=lambda x: x["name"].lower())

cache_dir = os.path.expanduser("~/.cache/quickshell")
os.makedirs(cache_dir, exist_ok=True)
with open(os.path.join(cache_dir, "apps.json"), "w", encoding="utf-8") as f:
    json.dump(unique_apps, f)