# MySQL 连接问题诊断脚本
# 运行此脚本排查 MySQL 连接问题

echo "=========================================="
echo "MySQL 连接问题诊断"
echo "=========================================="

# 1. 检查 MySQL 服务是否运行
echo ""
echo "1. 检查 MySQL 服务状态..."
if command -v systemctl &> /dev/null; then
    sudo systemctl status mysql 2>/dev/null || sudo systemctl status mysqld 2>/dev/null || echo "systemctl 不可用"
elif command -v service &> /dev/null; then
    sudo service mysql status 2>/dev/null || echo "service 不可用"
else
    docker ps | grep mysql || echo "MySQL 服务状态未知"
fi

# 2. 测试端口连接
echo ""
echo "2. 测试 MySQL 端口连接..."
if command -v nc &> /dev/null; then
    nc -zv 192.168.3.136 3306 2>&1 || echo "nc 测试失败"
elif command -v telnet &> /dev/null; then
    timeout 5 telnet 192.168.3.136 3306 2>&1 || echo "telnet 测试失败"
else
    echo "无法测试端口（nc/telnet 未安装）"
fi

# 3. 检查本地 MySQL 配置文件
echo ""
echo "3. MySQL 配置文件位置..."
find /etc -name "my.cnf" -o -name "mysql.cnf" 2>/dev/null | head -5

# 4. 尝试本地连接
echo ""
echo "4. 测试本地连接..."
mysql -u root -p -e "SELECT VERSION();" 2>/dev/null || echo "本地 root 连接失败"

# 5. 如果有 Docker，列出 MySQL 容器
echo ""
echo "5. Docker MySQL 容器..."
docker ps -a | grep mysql || echo "没有 MySQL 容器"

echo ""
echo "=========================================="
echo "诊断完成"
echo "=========================================="
echo ""
echo "常见解决方案："
echo ""
echo "方案 1: 使用 Docker Compose 启动 MySQL"
echo "  cd dev-data-service"
echo "  docker-compose -f docker-compose.mysql.yml up -d"
echo ""
echo "方案 2: 在远程 MySQL 服务器授权"
echo "  mysql -u root -h 192.168.3.136 -p"
echo "  CREATE USER 'cowork'@'%' IDENTIFIED BY 'your_password';"
echo "  GRANT ALL PRIVILEGES ON cowork_dev_data.* TO 'cowork'@'%';"
echo "  FLUSH PRIVILEGES;"
echo ""
echo "方案 3: 检查防火墙"
echo "  sudo ufw allow 3306/tcp"
echo "  sudo iptables -L -n | grep 3306"
