-- MySQL 服务器设置脚本
-- 在 MySQL 服务器上执行此脚本

-- ==========================================
-- 1. 创建数据库
-- ==========================================
CREATE DATABASE IF NOT EXISTS cowork_dev_data
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- ==========================================
-- 2. 创建用户（支持从任何 IP 连接）
-- ==========================================
-- 方法 A: 允许从任何 IP 连接
CREATE USER IF NOT EXISTS 'cowork'@'%' IDENTIFIED BY 'cowork_password';

-- 方法 B: 只允许特定 IP 段连接（更安全）
-- CREATE USER IF NOT EXISTS 'cowork'@'192.168.3.%' IDENTIFIED BY 'cowork_password';

-- ==========================================
-- 3. 授予权限
-- ==========================================
GRANT ALL PRIVILEGES ON cowork_dev_data.* TO 'cowork'@'%';

-- 如果使用特定 IP
-- GRANT ALL PRIVILEGES ON cowork_dev_data.* TO 'cowork'@'192.168.3.%';

-- ==========================================
-- 4. 刷新权限
-- ==========================================
FLUSH PRIVILEGES;

-- ==========================================
-- 5. 验证设置
-- ==========================================
-- 查看用户权限
SHOW GRANTS FOR 'cowork'@'%';

-- 查看数据库
SHOW DATABASES;

-- 查看用户
SELECT user, host FROM mysql.user WHERE user = 'cowork';

-- ==========================================
-- 6. 测试连接（从客户端）
-- ==========================================
-- mysql -u cowork -h <服务器IP> -p cowork_dev_data

-- ==========================================
-- 7. 远程连接故障排除
-- ==========================================
-- 如果仍然无法连接，检查：

-- 7.1 确认 MySQL 监听地址
-- 在 /etc/mysql/my.cnf 或 /etc/my.cnf 中添加：
-- bind-address = 0.0.0.0

-- 7.2 确认防火墙允许 3306 端口
-- sudo ufw allow 3306/tcp
-- sudo iptables -A INPUT -p tcp --dport 3306 -j ACCEPT

-- 7.3 重启 MySQL 服务
-- sudo systemctl restart mysql
-- 或
-- sudo systemctl restart mysqld

-- ==========================================
-- 8. 常见错误解决方案
-- ==========================================

-- 错误: Authentication plugin 'caching_sha2_password' is not supported
-- 解决: 使用旧版认证插件
ALTER USER 'cowork'@'%' IDENTIFIED WITH mysql_native_password BY 'cowork_password';
FLUSH PRIVILEGES;

-- 错误: Can't connect to MySQL server
-- 解决: 检查 MySQL 是否运行，以及端口是否正确
-- sudo netstat -tulnp | grep 3306
