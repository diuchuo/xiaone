#!/bin/bash

# 检查是否存在 CLOUDFLARE_TOKEN 环境变量
if [ ! -z "$CLOUDFLARE_TOKEN" ]; then
    echo "⚡ 检测到 Cloudflare Token，正在启动隧道..."
    # --- 修改点：去掉了 --no-autoupdate 参数 ---
    cloudflared tunnel run --token $CLOUDFLARE_TOKEN &
else
    echo "⚠️ 未检测到 CLOUDFLARE_TOKEN，仅启动本地服务。"
fi

# 启动主程序
echo "🚀 启动统一代理服务..."
exec node unified-server.js
