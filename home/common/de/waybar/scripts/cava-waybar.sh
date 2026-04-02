#!/usr/bin/env bash

bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"

# 建立 sed 字典：将 0-7 替换为对应的 unicode bar
for i in $(seq 0 7); do
    dict="${dict}s/$i/${bar:$i:1}/g;"
done

# 生成临时配置
config_file="/tmp/waybar_cava_config"
cat > "$config_file" <<EOF
[general]
framerate = 60
bars = 14

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7

[input]
method = pipewire
EOF

# 不使用管道，避免 cava 因 SIGPIPE 退出
while IFS= read -r line; do
    echo "$line" | sed "$dict"
done < <(cava -p "$config_file")

