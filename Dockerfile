FROM node:18-slim

# 安装必要的系统依赖（用于camoufox浏览器）
# 使用 --no-install-recommends 减小体积
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    ca-certificates \
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
    dumb-init \
    && rm -rf /var/lib/apt/lists/*

# 创建用户目录
RUN useradd -m -s /bin/bash user
WORKDIR /home/user

# 安装依赖
COPY package*.json ./
RUN npm install

# 复制应用文件
COPY unified-server.js dark-browser.js ./
COPY auth/ ./auth/
# 注意：确保本地有这个文件夹，或者通过 build 步骤下载
COPY camoufox-linux/ ./camoufox-linux/

# 设置文件权限
RUN chown -R user:user /home/user && \
    chmod +x /home/user/camoufox-linux/camoufox

# 切换到user用户
USER user

# 暴露端口
EXPOSE 8889

# 使用 dumb-init 作为入口点，处理信号转发
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# 启动命令
CMD ["node", "unified-server.js"]
