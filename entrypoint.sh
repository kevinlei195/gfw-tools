#!/bin/sh
set -e 

# 配置文件下载地址（用户通过环境变量传入）
CONFIG_URL=${CONFIG_URL:-""}

# 配置文件保存路径（默认 /app/config.yaml）
CONFIG_PATH=${CONFIG_PATH:-"/app/config.yaml"}

# 二进制程序路径（默认 /app/demo-app）
APP_PATH=${APP_PATH:-"/usr/local/bin/supervisord"}

download_config() {
    # 下载配置文件（使用wget，Alpine默认自带）
    echo "🚀 开始下载配置文件: $CONFIG_URL -> $CONFIG_PATH"
    if wget -O "$CONFIG_PATH" "$CONFIG_URL"; then
        echo "✅ 配置文件下载成功"
        # 可选：校验配置文件是否为空
        if [ ! -s "$CONFIG_PATH" ]; then
            echo "❌ 下载的配置文件为空，退出"
            exit 1
        fi
    else
        echo "❌ 配置文件下载失败"
        exit 1
    fi
}

start_app() {
    # 校验二进制程序是否存在
    if [ ! -f "$APP_PATH" ]; then
        echo "❌ 二进制程序不存在: $APP_PATH"
        exit 1
    fi

    # 赋予执行权限
    chmod +x "$APP_PATH"

    # 启动程序（传递所有参数）
    echo "🏁 启动二进制程序: $APP_PATH $@"
    exec "$APP_PATH" "$@"
}

main() {
     # 校验下载地址是否为空
    if [ -z "$CONFIG_URL" ]; then
        echo "❌ 启用配置文件下载但未指定CONFIG_URL，退出"
        start_app "$@"
    else
        download_config
        start_app "$@"
    fi
}

# 执行主流程
main "$@"