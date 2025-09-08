# RustDesk Server Full - API & Web Console

本仓库包含了 `rustdesk-api` (后端) 和 `rustdesk-api-web` (前端) 两个子模块，以及 RustDesk 官方的 `hbbs` 和 `hbbr` 服务，旨在提供一个完整、可自托管的 RustDesk 服务器解决方案。

## ✨ 功能特性

*   **完整的 RustDesk 服务**: 集成了 `hbbs` (ID/Rendezvous 服务器) 和 `hbbr` (中继服务器)。
*   **Web 管理后台**: 提供一个用户友好的 Web 界面来管理用户、设备、群组、日志等。
*   **用户和权限管理**: 支持用户注册、登录以及权限控制。
*   **设备管理**: 查看和管理已连接的客户端设备。
*   **地址簿**: 为用户提供云端地址簿功能。
*   **多种数据库支持**: 后端支持 SQLite, MySQL, 和 PostgreSQL。
*   **Docker 一键部署**: 通过 Docker Compose 提供简单快捷的部署方式。

---

## 🚀 快速入门 (Docker)


对于大多数用户，推荐使用 Docker Compose 进行快速部署。

### 1. 准备环境

*   安装 [Docker](https://docs.docker.com/get-docker/) 和 [Docker Compose](https://docs.docker.com/compose/install/)。

### 2. 启动服务

在项目根目录下，执行以下命令来构建并启动所有服务：

```bash
git clone --recursive https://github.com/rustdesk/rustdesk-full.git
docker compose up -d
```

服务启动后，您可以通过以下端口访问：

*   **API 服务**: `http://<your-server-ip>:11114`
*   **RustDesk ID/Rendezvous 服务 (hbbs)**: `11115` (TCP), `11116` (TCP/UDP)
*   **RustDesk 中继服务 (hbbr)**: `11117` (TCP), `11119` (TCP)

---

默认用户名&密码:admin

## 🛠️ 从源码构建

如果您是开发者，并希望对项目进行二次开发，可以按照以下步骤从源码构建。

### 1. 环境要求

*   **Go**: 用于构建后端 API。
*   **Node.js**: (建议 v16 或更高版本) 用于构建前端 Web 应用。
*   **Docker**: 如果您的目标平台是 Linux，构建后端时需要 Docker。

2.  执行构建脚本。脚本会根据您的参数编译适用于不同平台的二进制文件
    ```bash
    # 构建 macOS 版本
    ./build-full.sh darwin

    # 构建 Linux 版本 (需要 Docker)
    ./build-full.sh linux
    ```
3.  构建完成后，生成的可执行文件将位于 `release` 目录中。
