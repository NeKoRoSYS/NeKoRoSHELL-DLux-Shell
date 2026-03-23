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
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                name = ""
                icon = ""
                exec_cmd = ""
                nodisplay = False
                in_desktop_entry = False
                
                for line in f:
                    line = line.strip()
                    if not line or line.startswith('#'):
                        continue
                        
                    if line.startswith('['):
                        in_desktop_entry = (line == '[Desktop Entry]')
                        continue
                        
                    if in_desktop_entry:
                        if line.startswith("Name=") and not name:
                            name = line[5:].strip()
                        elif line.startswith("Icon=") and not icon:
                            icon = line[5:].strip()
                        elif line.startswith("Exec=") and not exec_cmd:
                            exec_cmd = line[5:].strip()
                        elif line.startswith("NoDisplay="):
                            if line[10:].strip().lower() == "true":
                                nodisplay = True
                                break 
                                
            if name and exec_cmd and not nodisplay:
                exec_cmd = exec_cmd.split("%")[0].strip()
                apps.append({"name": name, "icon": icon, "exec": exec_cmd})
        except Exception:
            pass

seen = set()
unique_apps = []
for app in apps:
    if app["name"] not in seen:
        seen.add(app["name"])
        unique_apps.append(app)

unique_apps.sort(key=lambda x: x["name"].lower())

cache_dir = os.path.expanduser("~/.cache/nekoroshell")
os.makedirs(cache_dir, exist_ok=True)
with open(os.path.join(cache_dir, "apps.json"), "w", encoding="utf-8") as f:
    json.dump(unique_apps, f)