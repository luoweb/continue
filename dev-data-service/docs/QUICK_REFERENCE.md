# Dev Data Service - 快速参考

## 🚀 快速启动

### 启动服务

```bash
# SQLite 模式（推荐首次使用）
docker run -d \
  --name cowork-dev-data-service \
  -p 8001:8001 \
  -e DB_TYPE=sqlite \
  dev-data-service:latest

# MySQL 模式
docker run -d \
  --name cowork-dev-data-service \
  -p 8001:8001 \
  -e DB_TYPE=mysql \
  -e DB_HOST=192.168.3.136 \
  -e DB_PORT=3306 \
  -e DB_USER=cowork \
  -e DB_PASSWORD=cowork_password \
  -e DB_NAME=cowork_dev_data \
  dev-data-service:latest
```

### 停止服务

```bash
docker stop cowork-dev-data-service
docker rm cowork-dev-data-service
```

## 🔍 测试命令

### 快速测试

```bash
# 快速测试（30秒）
chmod +x scripts/quick-test.sh
./scripts/quick-test.sh
```

### 完整测试

```bash
# 完整测试套件（2-3分钟）
chmod +x scripts/test-api.sh
./scripts/test-api.sh
```

### 手动测试

```bash
# 健康检查
curl http://localhost:8001/health

# 查看统计
curl http://localhost:8001/api/v1/stats

# 提交测试数据
curl -X POST http://localhost:8001/api/v1/data \
  -H "Content-Type: application/json" \
  -d '{"name":"test","data":{},"schema":"0.2.0"}'

# 查看数据
curl http://localhost:8001/api/v1/data?limit=5

# 查看事件类型
curl http://localhost:8001/api/v1/events
```

## 📡 API 端点

| 方法   | 端点                    | 说明           |
| ------ | ----------------------- | -------------- |
| GET    | /health                 | 健康检查       |
| POST   | /api/v1/data            | 提交数据       |
| GET    | /api/v1/data            | 查询数据       |
| GET    | /api/v1/stats           | 统计数据       |
| DELETE | /api/v1/data/old/{days} | 删除旧数据     |
| GET    | /api/v1/events          | 支持的事件类型 |
| POST   | /api/v1/tokens          | 创建 Token     |
| GET    | /api/v1/tokens          | 列出 Tokens    |
| DELETE | /api/v1/tokens/{name}   | 撤销 Token     |

## 🔐 认证命令

### 启用认证

```bash
# 启动时设置
docker run -d \
  --name cowork-dev-data-service \
  -p 8001:8001 \
  -e REQUIRE_AUTH=true \
  dev-data-service:latest
```

### 创建 Token

```bash
curl -X POST http://localhost:8001/api/v1/tokens \
  -H "Content-Type: application/json" \
  -d '{"name":"production","expires_days":30}'
```

### 使用 Token

```bash
curl http://localhost:8001/api/v1/stats \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## 🗄️ 数据库命令

### 查看数据库

```bash
# SQLite
sqlite3 dev_data.db "SELECT * FROM dev_data LIMIT 5;"

# MySQL
mysql -u cowork -h 192.168.3.136 -p cowork_dev_data \
  -e "SELECT * FROM dev_data LIMIT 5;"
```

### 清理数据

```bash
# 删除 30 天前的数据
curl -X DELETE http://localhost:8001/api/v1/data/old/30

# 删除所有数据
curl -X DELETE http://localhost:8001/api/v1/data/old/0
```

## 📊 常用查询

### 统计数据

```bash
# 总记录数
curl -s http://localhost:8001/api/v1/stats | \
  python3 -c "import json,sys; d=json.load(sys.stdin); print(f'总数: {d[\"total_records\"]}')"

# 按事件统计
curl -s http://localhost:8001/api/v1/stats | \
  python3 -c "import json,sys; d=json.load(sys.stdin); print(json.dumps(d['by_event'], indent=2))"

# 最近 7 天趋势
curl -s http://localhost:8001/api/v1/stats | \
  python3 -c "import json,sys; d=json.load(sys.stdin); print(json.dumps(d['last_7_days'], indent=2))"
```

### 查询特定数据

```bash
# 查询聊天记录
curl -s "http://localhost:8001/api/v1/data?event_name=chatInteraction&limit=10"

# 查询 Token 使用
curl -s "http://localhost:8001/api/v1/data?event_name=tokensGenerated&limit=5"

# 按日期查询
curl -s "http://localhost:8001/api/v1/data?start_date=2024-01-01&end_date=2024-01-31"
```

## 🐳 Docker Compose

### SQLite + Service

```bash
docker-compose up -d
docker-compose logs -f
docker-compose down
```

### MySQL + Service

```bash
docker-compose -f docker-compose.mysql.yml up -d
docker-compose -f docker-compose.mysql.yml logs -f
docker-compose -f docker-compose.mysql.yml down
```

## 📁 文件结构

```
dev-data-service/
├── scripts/
│   ├── test-api.sh          # 完整测试套件
│   ├── quick-test.sh        # 快速测试
│   ├── diagnose-mysql.sh    # MySQL 诊断
│   ├── setup-mysql.sh       # MySQL 设置
│   └── mysql-server-setup.sql # MySQL SQL
├── docs/
│   ├── README.md            # 完整文档
│   ├── API_TESTING_GUIDE.md # 测试指南
│   ├── TOKEN_AUTH_GUIDE.md  # 认证指南
│   └── MYSQL_TROUBLESHOOTING.md # MySQL 故障排查
├── main.py                  # 主应用
├── database.py              # 数据库模块
├── Dockerfile               # Docker 构建
└── docker-compose.yml       # Docker Compose
```

## 🔧 故障排查

### 服务无法启动

```bash
# 查看日志
docker logs cowork-dev-data-service

# 检查端口占用
netstat -tulpn | grep 8001
```

### 数据库连接失败

```bash
# 运行诊断脚本
./scripts/diagnose-mysql.sh

# 查看 MySQL 故障排查文档
cat docs/MYSQL_TROUBLESHOOTING.md
```

### API 返回错误

```bash
# 查看详细错误
curl -v http://localhost:8001/api/v1/data

# 运行完整测试
./scripts/test-api.sh 2>&1 | grep -A 5 "✗"
```

## 📈 性能优化

### 响应时间基准

- 健康检查: < 50ms
- 统计查询: < 200ms
- 数据提交: < 500ms
- 大数据查询: < 2s

### 优化建议

- 使用索引：`event_name`, `created_at`, `user_id`
- 限制查询：`?limit=100&offset=0`
- 定期清理：`DELETE /api/v1/data/old/90`

## 🆘 获取帮助

### 查看完整文档

```bash
cat docs/README.md
cat docs/API_TESTING_GUIDE.md
```

### 查看 API 文档

打开浏览器访问：`http://localhost:8001/docs`

### 运行诊断

```bash
./scripts/test-api.sh 2>&1 | tee test-results.txt
```

## 📝 环境变量

| 变量          | 说明        | 默认值          |
| ------------- | ----------- | --------------- |
| HOST          | 监听地址    | 0.0.0.0         |
| PORT          | 监听端口    | 8001            |
| DB_TYPE       | 数据库类型  | sqlite          |
| DATABASE_PATH | SQLite 路径 | ./dev_data.db   |
| DB_HOST       | MySQL 主机  | localhost       |
| DB_PORT       | MySQL 端口  | 3306            |
| DB_USER       | 数据库用户  | root            |
| DB_PASSWORD   | 数据库密码  | -               |
| DB_NAME       | 数据库名    | cowork_dev_data |
| REQUIRE_AUTH  | 启用认证    | false           |

---

**最后更新**: 2024-05-24
