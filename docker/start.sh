#!/usr/bin/env bash
# CRMEB Docker 一键启动脚本
# 作用：设置安装程序要求的目录/文件可写权限，然后启动整套环境
set -e

# 切到项目根目录（脚本位于 docker/ 下）
cd "$(dirname "$0")/.."

echo "=== 1. 设置目录/文件可写权限 ==="
mkdir -p crmeb/backup
# 安装向导权限检查项：backup / public / runtime / .env / .version / .constant
chmod -R 777 crmeb/runtime crmeb/public crmeb/backup 2>/dev/null || true
chmod 777 crmeb/.env crmeb/.version crmeb/.constant 2>/dev/null || true

echo "=== 2. 构建并启动环境 ==="
docker compose up -d --build

echo ""
echo "=== 启动完成 ==="
echo "移动端/H5 首页: http://localhost:8011/"
echo "后台管理:      http://localhost:8011/admin"
echo "查看状态:      docker compose ps"
echo "查看日志:      docker compose logs -f"
