# MySQL 连接完整解决方案

## 🚨 问题描述

```
ERROR 1045 (28000): Access denied for user 'cowork'@'192.168.3.136' (using password: YES)
```

## ✅ 解决方案

### 方案 1: 使用 Docker Compose 启动完整环境（推荐）

```bash
# 进入项目目录
cd /volume1/block/code/cowork/dev-data-service

# 启动 MySQL + Dev Data Service
docker-compose -f docker-compose.mysql.yml up -d

# 查看日志
docker-compose -f docker-compose.mysql.yml logs -f

# 测试服务
curl http://localhost:8001/health
```

### 方案 2: 在现有 MySQL 服务器授权

#### 步骤 1: 登录 MySQL 服务器

```bash
# 在 MySQL 服务器上执行
mysql -u root -p
```

#### 步骤 2: 运行设置脚本

```bash
# 将 scripts/mysql-server-setup.sql 上传到 MySQL 服务器
mysql -u root -p < mysql-server-setup.sql
```

#### 步骤 3: 测试连接

```bash
# 从客户端测试
mysql -u cowork -h 192.168.3.136 -P3306 -p cowork_dev_data
```

### 方案 3: 手动授权命令

如果不想使用脚本，逐条执行以下命令：

```sql
-- 1. 创建数据库
CREATE DATABASE IF NOT EXISTS cowork_dev_data
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- 2. 创建用户（允许从任何 IP 连接）
CREATE USER 'cowork'@'%' IDENTIFIED BY 'cowork_password';

-- 3. 授予权限
GRANT ALL PRIVILEGES ON cowork_dev_data.* TO 'cowork'@'%';

-- 4. 刷新权限
FLUSH PRIVILEGES;
```

## 🔍 诊断步骤

### 1. 运行诊断脚本

```bash
chmod +x scripts/diagnose-mysql.sh
./scripts/diagnose-mysql.sh
```

### 2. 检查 MySQL 日志

```bash
# Docker 日志
docker logs cowork_dev_data_mysql

# 系统日志
sudo tail -f /var/log/mysql/error.log
```

### 3. 测试网络连接

```bash
# 测试端口
nc -zv 192.168.3.136 3306

# 测试 telnet
telnet 192.168.3.136 3306
```

## 🛡️ 常见权限问题

### 问题 1: 用户不存在

**症状**: `Access denied for user 'cowork'@'192.168.3.136'`

**解决**:

```sql
CREATE USER 'cowork'@'%' IDENTIFIED BY 'cowork_password';
GRANT ALL PRIVILEGES ON cowork_dev_data.* TO 'cowork'@'%';
FLUSH PRIVILEGES;
```

### 问题 2: 密码错误

**症状**: `Access denied for user 'cowork'@'192.168.3.136' (using password: YES)`

**解决**: 确认密码正确，或重置密码

```sql
ALTER USER 'cowork'@'%' IDENTIFIED BY 'correct_password';
FLUSH PRIVILEGES;
```

### 问题 3: IP 地址限制

**症状**: 本地可以连接，远程无法连接

**解决**:

```sql
-- 允许特定 IP
CREATE USER 'cowork'@'192.168.3.136' IDENTIFIED BY 'cowork_password';
GRANT ALL PRIVILEGES ON cowork_dev_data.* TO 'cowork'@'192.168.3.136';

-- 或允许整个网段
CREATE USER 'cowork'@'192.168.3.%' IDENTIFIED BY 'cowork_password';
GRANT ALL PRIVILEGES ON cowork_dev_data.* TO 'cowork'@'192.168.3.%';

FLUSH PRIVILEGES;
```

### 问题 4: MySQL 绑定地址问题

**症状**: `Can't connect to MySQL server on '192.168.3.136'`

**解决**: 修改 MySQL 配置

编辑 `/etc/mysql/my.cnf` 或 `/etc/my.cnf`:

```ini
[mysqld]
bind-address = 0.0.0.0
# 或
# bind-address = 0.0.0.0
# skip-networking = OFF
```

重启 MySQL:

```bash
sudo systemctl restart mysql
```

### 问题 5: 防火墙阻止

**症状**: 网络可以 ping 通，但无法连接 3306 端口

**解决**:

```bash
# Ubuntu/Debian
sudo ufw allow 3306/tcp

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload
```

## 📝 配置 dev-data-service

### 更新 .env 文件

创建 `.env` 文件：

```bash
# Server settings
HOST=0.0.0.0
PORT=8001

# Database settings
DB_TYPE=mysql
DB_HOST=192.168.3.136
DB_PORT=3306
DB_USER=cowork
DB_PASSWORD=cowork_password
DB_NAME=cowork_dev_data
DB_CHARSET=utf8mb4

# Authentication
REQUIRE_AUTH=true
```

### 启动服务

```bash
# 停止之前的容器
docker stop cowork-dev-data-service
docker rm cowork-dev-data-service

# 使用环境变量启动
docker run -d \
  --name cowork-dev-data-service \
  -p 8001:8001 \
  --env-file .env \
  dev-data-service:latest
```

## ✅ 验证步骤

### 1. 测试 MySQL 连接

```bash
mysql -u cowork -h 192.168.3.136 -P3306 -p cowork_dev_data \
  -e "SELECT 'Connection successful!' AS status;"
```

### 2. 测试 Dev Data Service

```bash
# 健康检查
curl http://localhost:8001/health

# 提交测试数据
curl -X POST http://localhost:8001/api/v1/data \
  -H "Content-Type: application/json" \
  -d '{
    "name": "test",
    "data": {"message": "test"},
    "schema": "0.2.0"
  }'
```

### 3. 查看统计数据

```bash
curl http://localhost:8001/api/v1/stats
```

## 🆘 如果仍然无法连接

### 收集诊断信息

```bash
# 保存诊断日志
./scripts/diagnose-mysql.sh > diagnose.log 2>&1

# 查看 MySQL 版本和配置
mysql -u root -p -e "SHOW VARIABLES LIKE '%version%';"
mysql -u root -p -e "SHOW VARIABLES LIKE 'bind_address';"
```

### 获取帮助

请提供以下信息：

1. MySQL 服务器操作系统和版本
2. MySQL 版本: `mysql --version`
3. 诊断脚本输出: `./scripts/diagnose-mysql.sh`
4. MySQL 错误日志: `docker logs cowork_dev_data_mysql` 或 `/var/log/mysql/error.log`
5. 防火墙状态: `sudo ufw status` 或 `sudo iptables -L -n`

---

## 📞 快速联系信息

如果您需要帮助，请在提交 issue 时包含：

- 完整的错误信息
- 诊断脚本的完整输出
- 您的 MySQL 配置文件（脱敏后）
