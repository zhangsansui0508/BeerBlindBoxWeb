#!/bin/bash

cd Public
for file in *.png; do
    if [ -f "$file" ]; then
        # 移除文件名中的 @1x 和数字后缀
        new_name=$(echo "$file" | sed 's/@1x.*\.png/.png/' | sed 's/ (.*)\.png/.png/')
        if [ "$file" != "$new_name" ]; then
            mv "$file" "$new_name"
        fi
    fi
done 