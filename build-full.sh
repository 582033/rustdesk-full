#!/bin/bash

# 如果任何命令失败，脚本将立即退出
set -e

# --- 配置 ---
# 后端编译后的产物名称
BACKEND_ARTIFACT_NAME="apimain"
# 后端和前端的源目录
API_SRC_DIR="rustdesk-api"
WEB_SRC_DIR="rustdesk-api-web"
# 输出目录 (使用项目中已存在的拼写错误的目录名)
RELEASE_DIR="realese"

# --- 平台检查 ---
if [ -z "$1" ]; then
  echo "错误: 未指定构建平台。"
  echo "用法: ./build-full.sh <platform>"
  echo "支持的平台: 'darwin', 'linux'"
  exit 1
fi
PLATFORM=$1

# --- 1. 构建后端 ---
echo "--> 正在为平台 '$PLATFORM' 构建后端 ($API_SRC_DIR)..."
(cd "$API_SRC_DIR" && go mod tidy && go mod vendor && ./build.sh "$PLATFORM")
echo "--> 后端构建完成。"
echo

# --- 2. 构建前端 ---
echo "--> 正在构建前端 ($WEB_SRC_DIR)..."
(
  cd "$WEB_SRC_DIR"
  # 如果 node_modules 目录不存在，则运行 npm install
  if [ ! -d "node_modules" ]; then
    echo "    'node_modules' 目录未找到，正在运行 'npm install'..."
    npm install
  fi
  npm run build
)
echo "--> 前端构建完成。"
echo

# --- 3. 准备输出目录并复制文件 ---
echo "--> 正在将构建产物复制到 '$RELEASE_DIR' 目录..."

# 确保目标目录存在
mkdir -p "$RELEASE_DIR/resources/admin"

# --- 复制后端产物 ---
BACKEND_SRC_PATH="$API_SRC_DIR/release/$BACKEND_ARTIFACT_NAME"
BACKEND_DEST_PATH="$RELEASE_DIR/$BACKEND_ARTIFACT_NAME"

if [ -f "$BACKEND_SRC_PATH" ]; then
  cp "$BACKEND_SRC_PATH" "$BACKEND_DEST_PATH"
  echo "    - 已复制后端: $BACKEND_SRC_PATH -> $BACKEND_DEST_PATH"
else
  echo "错误: 在 $BACKEND_SRC_PATH 未找到后端产物，请检查后端构建是否成功。"
  exit 1
fi

# --- 复制前端产物 ---
FRONTEND_SRC_PATH="$WEB_SRC_DIR/dist/"
FRONTEND_DEST_PATH="$RELEASE_DIR/resources/admin/"

# 使用 rsync 来确保目标目录与源目录内容一致
rsync -a --delete "$FRONTEND_SRC_PATH" "$FRONTEND_DEST_PATH"
echo "    - 已复制前端: $FRONTEND_SRC_PATH -> $FRONTEND_DEST_PATH"
echo

echo "✅ 构建流程成功完成！"
