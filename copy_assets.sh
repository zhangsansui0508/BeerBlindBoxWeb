#!/bin/bash

# 创建 Public 目录（如果不存在）
mkdir -p Public

# 复制所有图片资源
cp -r ../../啤酒盲盒demo尝试/Assets.xcassets/*.imageset/*.png Public/

# 重命名图片文件
cd Public
for file in *.png; do
    if [ -f "$file" ]; then
        # 移除文件名中的 @1x 和数字后缀
        new_name=$(echo "$file" | sed 's/@1x.*\.png/.png/' | sed 's/ (.*)\.png/.png/')
        mv "$file" "$new_name"
    fi
done 