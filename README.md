# GFW-Node-Transit 

节点中转 运行在 x86-64

### 实现效果:

- 主要是为加速 binance 交易;

### 技术要去

- binance 地区限制, 最近且速度快的节点: 日本, 新加坡, 韩国, 台湾

### 实现过程

- 端口转发方案:

直接转发到落地节点的端口, 

> 通过 xray 实现端口直接转发,

适合自建节点,节点端口少的场景; 因为机场的服务器和节点都是不受我控制;

- 使用 xray + mihomo 中继

> xray 作为过墙的工具

### 实际落地方案

- 香港中继 mihmo 连接机场的直连落地节点;
- 香港中继 xray 连接 mihom 暴露端口 -> 回国;
- 国内中继再次加速;

流出的节点类型:

- 香港中继
- 国内中继
- 国内直连: 国内中继落地机场

#### 构建快速启动容器镜像

实现 GitHub 项目自动构建 Docker 镜像，核心是利用 GitHub Actions（GitHub 内置的 CI/CD 工具）结合 Docker 生态（Docker Hub/ghcr.io 等镜像仓库）完成自动化流程

整合常见的代理工具: xray mihomo hysteria2 sing-box(anytls)

实现的功能:

- docker-compsoe 部署;
- 部署时传入本地启动程序镜像 和 相应的配置文件URL;

来至于这个项目
https://gitea.com/ikon-la.com/xray-mihomo-hysteria


#### download releases

demo
```sh
curl -s https://api.github.com/repos/nginx/nginx/releases/latest | grep browser_download_url | cut -d'"' -f4

links=$(curl -s https://api.github.com/repos/nginx/nginx/releases/latest | grep browser_download_url | cut -d'"' -f4 |grep -E 'tar.gz$')
echo "${links}"

links=$(curl -s https://api.github.com/repos/nginx/nginx/releases/latest | grep browser_download_url | cut -d'"' -f4)

for url in $links; do
    wget $url
done
```

anytls
```sh
curl -sSL -o anytls-linux-amd64.zip $()
```