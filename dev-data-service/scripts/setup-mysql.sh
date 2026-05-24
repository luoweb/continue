#!/bin/bash
# MySQL 快速设置脚本 - 适用于 Docker 环境

set -e

echo "========================================"
echo "MySQL 快速设置脚本"
echo "========================================"

# 配置变量
MYSQL_HOST="${1:-192.168.3.136}"
MYSQL_PORT="${2:-3306}"
MYSQL_ROOT_PASSWORD="${3:-root_password}"
DB_NAME="cowork_dev_data"
DB_USER="cowork"
DB_PASSWORD="cowork_password"

echo ""
echo "配置信息:"
echo "  MySQL Host: $MYSQL_HOST"
echo "  MySQL Port: $MYSQL_PORT"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo ""

# 检查是否需要交互式输入
if [ "$MYSQL_HOST" = "192.168.3.136" ] && [ "$MYSQL_PORT" = "3306" ]; then
    read -p "使用默认配置? (Y/n): " confirm
    if [ "$confirm" = "n" ] || [ "$confirm" = "N" ]; then
        read -p "MySQL Host: " MYSQL_HOST
        read -p "MySQL Port: " MYSQL_PORT
        read -p "MySQL Root Password: " MYSQL_ROOT_PASSWORD
    fi
fi

echo ""
echo "1. 等待 MySQL 服务就绪..."
echo ""

# 尝试连接 MySQL，直到成功
MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1;" > /dev/null 2>&1; then
        echo "✓ MySQL 连接成功"
        break
    fi

    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "  等待 MySQL 就绪... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 2

    if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
        echo "✗ 无法连接到 MySQL"
        echo ""
        echo "请检查:"
        echo "  1. MySQL 服务是否运行"
        echo "  2. IP 地址和端口是否正确"
        echo "  3. 防火墙是否允许连接"
        exit 1
    fi
done

echo ""
echo "2. 创建数据库..."
mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u root -p"$MYSQL_ROOT_PASSWORD" << EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
EOF
echo "✓ 数据库 $DB_NAME 已创建"

echo ""
echo "3. 创建用户..."
mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u root -p"$MYSQL_ROOT_PASSWORD" << EOF
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;
EOF
echo "✓ 用户 $DB_USER 已创建并授权"

echo ""
echo "4. 验证设置..."
mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$DB_USER" -p"$DB_PASSWORD" << EOF
USE $DB_NAME;
SELECT '数据库连接测试成功!' AS status;
EOF
echo "✓ 验证成功"

echo ""
echo "========================================"
echo "✓ MySQL 设置完成!"
echo "========================================"
echo ""
echo "连接信息:"
echo "  Host: $MYSQL_HOST"
echo "  Port: $MYSQL_PORT"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo "  Password: $DB_PASSWORD"
echo ""
echo "测试连接:"
echo "  mysql -u $DB_USER -h $MYSQL_HOST -P $MYSQL_PORT -p $DB_NAME"
echo ""
echo "下一步:"
echo "  1. 更新 .env 文件"
echo "  2. 启动 dev-data-service"
echo "  3. 测试 API"
echo ""
