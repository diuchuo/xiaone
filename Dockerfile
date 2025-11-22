FROM node:18-slim

# 1. 安装系统依赖 (包含 camoufox 依赖和 wget)
# 移除非必要的 lib 可能会导致 camoufox 无法启动，所以保留原样
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libxss1 \
    libxtst6 \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# 2. 安装 Cloudflare Tunnel (cloudflared)
RUN wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# 创建用户目录
RUN useradd -m -s /bin/bash user
WORKDIR /home/user

# 安装依赖
COPY package*.json ./
RUN npm install

# 复制应用文件
COPY unified-server.js dark-browser.js ./
COPY auth/ ./auth/
COPY camoufox-linux/ ./camoufox-linux/

# 3. 复制启动脚本
COPY start.sh ./

# 设置权限 & 修复 Windows 换行符问题
RUN chown -R user:user /home/user && \
    chmod +x /home/user/camoufox-linux/camoufox && \
    chmod +x /home/user/start.sh && \
    sed -i 's/\r$//' /home/user/start.sh

# 切换到user用户
USER user

# [关键优化] 限制 Node.js 堆内存为 128MB
# Render 的免费实例只有 512MB，Node 默认可能占用过多，
# 我们将 Node 限制得很小，把剩余内存留给 Camoufox 浏览器。
ENV NODE_OPTIONS="--max-old-space-size=128"
ENV FORCE_COLOR=1

# 暴露端口
EXPOSE 8889

# 4. 启动命令指向脚本
CMD ["./start.sh"]
