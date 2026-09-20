#!/usr/bin/env bash

CONFIG="$1/config.json"

wallpaper_path=$(jq -r '.wallpaper_path' "$CONFIG" | envsubst)
cache_path=$(jq -r '.cache_path' "$CONFIG" | envsubst)
cache_batch_size=$(jq -r '.cache_batch_size' "$CONFIG")

mkdir -p "$cache_path"

echo "Wallpaper path: $wallpaper_path"
echo "Cache path: $cache_path"


find "$wallpaper_path" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -printf "%P\n" |
while IFS= read -r img; do
    input_file="$wallpaper_path/$img"
    output_file="$cache_path/$img"

    if [[ -f "$output_file" ]]; then
        continue
    fi

    mkdir -p "$(dirname "$output_file")"

    echo "Generating thumbnail for $img"
    magick "$input_file" -thumbnail x1000 -fuzz 10% -trim -strip "$output_file" &

    if (( cache_batch_size > 0 )); then
        while (( $(jobs -rp | wc -l) >= cache_batch_size )); do
            wait -n
        done
    fi
done

wait
echo "Thumbnail generation complete."
