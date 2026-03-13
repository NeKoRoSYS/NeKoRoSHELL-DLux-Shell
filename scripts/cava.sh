#!/bin/bash

# You can customize the look by changing these characters
# Classic blocks: "  ▂▃▄▅▆▇█"
# Lines:          " ▏▎▍▌▋▊▉█"
# Custom blocks:  " ▤▥▧▨▩"
dict="  ▂▃▄▅▆▇█"

# Number of visualizer bars you want
bar_count=10

dict_len=${#dict}
max_val=$((dict_len - 1))

config_file="/tmp/quickshell_cava.conf"
cat > "$config_file" <<EOF
[general]
framerate = 60
bars = $bar_count

[input]
# You can change this to "pulse" or "pipewire" if "auto" gives you trouble
method = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = $max_val
EOF

cava -p "$config_file" | while read -r line; do
    IFS=';' read -ra values <<< "$line"
    
    output=""
    for val in "${values[@]}"; do
        if [[ -n "$val" ]] && [[ "$val" =~ ^[0-9]+$ ]]; then
            if (( val > max_val )); then
                val=$max_val
            fi
            output+="${dict:$val:1}"
        fi
    done
    
    echo "$output"
done