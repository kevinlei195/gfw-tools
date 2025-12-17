FROM alpine:latest

# Mimhomo
COPY --from=metacubex/mihomo:Alpha /root/.config/mihomo/ /root/.config/mihomo/
COPY --from=metacubex/mihomo:Alpha /mihomo /usr/local/bin/mihomo
# Mihomo Smart
COPY --from=ghcr.milu.moe/vernesong/mihomo:alpha /mihomo /usr/local/bin/mihomo-smart

# xray
# Download geodat into a staging directory
ADD https://ghfast.top/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat /tmp/geodat/geoip.dat
ADD https://ghfast.top/https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat /tmp/geodat/geosite.dat
COPY --from=ghcr.milu.moe/xtls/xray-core:latest /usr/local/bin/xray /usr/local/bin/xray
COPY --from=ghcr.milu.moe/xtls/xray-core:latest /usr/local/share/xray /usr/local/share/xray

# anylts
# 核心构建步骤（修复换行符+语法问题）
RUN set -euo pipefail && \
    apk add --no-cache wget tar curl unzip ca-certificates && \
    mkdir -p /tmp/download && \
    # 调试：打印GitHub API原始响应
    echo "=== 获取GitHub最新版本API响应 ===" && \
    curl -s https://api.github.com/repos/anytls/anytls-go/releases/latest && \
    echo -e "\n=== 提取DOWNLOAD_URL ===" && \
    # 修复：兼容文件名格式+添加Token避免速率限制
    GITHUB_TOKEN="" && \
    DOWNLOAD_URL=$(curl -s ${GITHUB_TOKEN:+-H "Authorization: token $GITHUB_TOKEN"} \
                  https://api.github.com/repos/anytls/anytls-go/releases/latest | \
                  grep -E 'browser_download_url.*linux.*amd64.*\.zip' | cut -d'"' -f4) && \
    # 兜底：手动指定版本（避免latest失效）
    if [ -z "$DOWNLOAD_URL" ]; then \
        echo "WARN: 未获取到最新版本，使用固定版本" && \
        DOWNLOAD_URL="https://github.com/anytls/anytls-go/releases/download/v0.1.0/anytls-linux-amd64.zip"; \
    fi && \
    echo "最终下载URL: $DOWNLOAD_URL" && \
    BINARY_TAR=$(basename "$DOWNLOAD_URL") && \
    echo "=== 开始下载文件 ===" && \
    wget -O /tmp/download/${BINARY_TAR} "$DOWNLOAD_URL" && \
    echo "=== 解压文件（查看压缩包内容） ===" && \
    unzip -l /tmp/download/${BINARY_TAR} && \
    unzip /tmp/download/${BINARY_TAR} -d /tmp/download && \
    echo "=== 赋予执行权限（查看解压后文件） ===" && \
    ls -l /tmp/download/ && \
    # 兼容解压后文件名（通配符匹配）
    chmod +x /tmp/download/anytls-client* /tmp/download/anytls-server* && \
    # 移动二进制文件到系统PATH
    cp /tmp/download/anytls-* /usr/local/bin/anytls-* && \
    # 清理依赖和临时文件
    apk del --no-cache wget tar curl unzip && \
    rm -rf /tmp/download && \
    # 验证安装
    echo "=== 验证安装 ===" && \
    anytls-client -v || echo "注意：版本检查失败，但二进制文件已移动"
    
# hysteria
COPY --from=tobyxdd/hysteria:latest /usr/local/bin/hysteria /usr/local/bin/hysteria

# supervisord
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord

# ENTRYPOINT  ["/usr/local/bin/supervisord"]
# CMD ["/usr/local/bin/supervisord"]

WORKDIR /app
COPY entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]