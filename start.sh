#!/bin/bash

# 检查是否存在 CLOUDFLARE_TOKEN 环境变量
if [ ! -z "$CLOUDFLARE_TOKEN" ]; then
    echo "⚡ 检测到 Cloudflare Token，正在启动隧道..."
    # 启动 cloudflared，--no-autoupdate 防止容器内更新报错
    # & 符号让其在后台运行
    cloudflared tunnel run --token $CLOUDFLARE_TOKEN --no-autoupdate &
else
    echo "⚠️ 未检测到 CLOUDFLARE_TOKEN，仅启动本地服务。"
fi

# 等待几秒确保 tunnel 启动日志输出（可选）
sleep 2

# 启动主程序 (exec 确保接收信号)
echo "🚀 启动统一代理服务..."
exec node unified-server.js
