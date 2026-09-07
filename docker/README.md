# CRMEB Docker Compose 部署

本目录配合项目根目录的 `docker-compose.yml` 使用，一条命令在项目根目录启动整套运行环境。

## 环境要求

- Docker 20.10+
- Docker Compose v2（`docker compose` 命令）

## 快速启动

在项目根目录执行：

```bash
# 1. 用本地代码构建 PHP 镜像（首次或代码结构变化后执行）
docker compose build

# 2. 启动整套环境
docker compose up -d
```

> 说明：MySQL / Redis / Nginx 直接使用官方预构建镜像；**PHP 镜像基于本地代码构建**
> （`docker/php/Dockerfile`），并挂载本地 `crmeb/` 目录，本地改动会立即同步到容器。
> 首次启动会拉取基础镜像并初始化 MySQL，请耐心等待（镜像较大，约 1GB+）。

## 本地改代码如何生效

- **PHP 代码（控制器 / 服务 / 模型等）**：已通过 bind mount 挂载 `./crmeb:/var/www`，
  保存文件后**立即生效**，无需重启或重新构建。
- **`.env` / `config/` 配置、composer 依赖变化、镜像层（Dockerfile）变化**：
  需要重启容器或重新构建：
  ```bash
  docker compose restart phpfpm        # 配置改动后重启
  docker compose up -d --build phpfpm  # 依赖/镜像变化后重建
  ```
- 若生产环境不想依赖挂载（希望镜像自带代码、可分发），
  将 `docker-compose.yml` 中 `phpfpm` 的 `volumes: - ./crmeb:/var/www` 去掉后重新构建即可。

## 服务与端口

| 服务      | 容器名       | 主机端口 | 容器端口 | 说明                     |
|-----------|--------------|----------|----------|--------------------------|
| nginx     | crmeb_nginx  | 8011     | 80       | Web 服务入口             |
| phpfpm    | crmeb_php    | 9000     | 9000     | PHP-FPM                  |
| phpfpm    | crmeb_php    | 40001    | 40001    | Workerman 公告通知长连接 |
| phpfpm    | crmeb_php    | 40002    | 40002    | Workerman 客服消息长连接 |
| mysql     | crmeb_mysql  | 33061    | 3306     | MySQL 数据库             |
| redis     | crmeb_redis  | 63791    | 6379     | Redis 缓存               |

## 访问地址

- 移动端 / H5 首页：http://localhost:8011/
- 后台管理：http://localhost:8011/admin （首次访问进入安装向导）

## 安装向导数据库信息

| 项     | 值         |
|--------|------------|
| Host   | mysql      |
| 端口   | 3306       |
| 用户   | crmeb      |
| 密码   | 123456     |
| 数据库 | crmeb      |

> 注：`mysql` / `redis` 为 Docker 网络内的服务名，请勿填写 `localhost`。

## 配置项（可选）

通过环境变量覆盖默认值，例如：

```bash
# 修改对外端口与数据库密码
NGINX_PORT=8080 MYSQL_PORT=33061 REDIS_PORT=63791 MYSQL_PASSWORD=your_pass \
docker compose up -d
```

| 变量                | 默认值 |
|---------------------|--------|
| NGINX_PORT          | 8011   |
| MYSQL_PORT          | 33061  |
| REDIS_PORT          | 63791  |
| MYSQL_ROOT_PASSWORD | 123456 |
| MYSQL_USER          | crmeb  |
| MYSQL_PASSWORD      | 123456 |
| MYSQL_DATABASE      | crmeb  |
| REDIS_PASSWORD      | 123456 |

## 常用命令

```bash
docker compose up -d            # 启动
docker compose down             # 停止并删除容器（保留数据）
docker compose down -v          # 停止并删除容器和数据卷
docker compose logs -f nginx    # 查看 nginx 日志
docker compose restart          # 重启
```

## 数据持久化

- MySQL 数据：`docker/mysql/data/`
- Redis 数据：`docker/redis/data/`
- Nginx 日志：`docker/nginx/log/`

这些目录已加入 `.gitignore`，不会提交到仓库。

## 常见问题

MySQL 初始化失败（`--initialize specified but the data directory has files in it`）：

```bash
docker compose down
rm -rf docker/mysql/data/*
docker compose up -d
```
