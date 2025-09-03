#!/bin/sh

# 启动 hbbr 进程
#/app/hbbr -k /app/key/id_ed25519 &
/app/hbbr -k _ &
echo "hbbr started"

# 启动 hbbs 进程
/app/hbbs -k _ &
echo "hbbs started"

# 启动 apimain 进程（在前台）
/app/apimain
echo "apimain started"
