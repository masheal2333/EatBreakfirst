#!/bin/bash

# 获取源 Info.plist 路径
SOURCE_INFO_PLIST="${SRCROOT}/EatBreakFirst/Info.plist"

# 获取目标 Info.plist 路径
TARGET_INFO_PLIST="${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"

# 确保目标目录存在
mkdir -p "$(dirname "$TARGET_INFO_PLIST")"

# 复制 Info.plist 文件
cp "$SOURCE_INFO_PLIST" "$TARGET_INFO_PLIST"

# 输出信息
echo "Info.plist 已从 $SOURCE_INFO_PLIST 复制到 $TARGET_INFO_PLIST"

exit 0 