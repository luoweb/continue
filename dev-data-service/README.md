# Continue Dev Data Service

一个用于收集和管理 Continue 开发数据的后端服务。

## 🚀 快速开始

### 启动服务

```bash
# SQLite 模式
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
  -e DB_USER=cowork \
  -e DB_PASSWORD=cowork_password \
  -e DB_NAME=cowork_dev_data \
  dev-data-service:latest
```

### 测试服务

```bash
# 快速测试（30秒）
chmod +x scripts/quick-test.sh
./scripts/quick-test.sh

# 完整测试套件（2-3分钟）
chmod +x scripts/test-api.sh
./scripts/test-api.sh

# 手动测试
curl http://localhost:8001/health
```

## 📖 文档目录

详细文档请查看 [docs/](docs/) 目录：

- [docs/README.md](docs/README.md) - 完整使用指南
- [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) - 快速参考卡片
- [docs/TOKEN_AUTH_GUIDE.md](docs/TOKEN_AUTH_GUIDE.md) - Token 认证机制详解
- [docs/API_TESTING_GUIDE.md](docs/API_TESTING_GUIDE.md) - API 测试完整指南
- [docs/MYSQL_TROUBLESHOOTING.md](docs/MYSQL_TROUBLESHOOTING.md) - MySQL 故障排查

## 🎯 主要功能

- 📊 收集 Continue dev_data 事件
- 🗄️ 支持 SQLite 和 MySQL
- 🔐 Token 认证机制
- 🐳 Docker 部署支持
- 📈 统计和查询功能
- ✅ 自动化测试套件

## 🔍 测试脚本

### 快速测试脚本

```bash
# 快速验证服务状态（30秒）
./scripts/quick-test.sh
```

测试内容：

- ✅ 服务健康检查
- ✅ 数据库连接
- ✅ 数据提交测试
- ✅ 事件类型支持
- ✅ API 文档访问

### 完整测试套件

```bash
# 完整 API 测试（2-3分钟）
./scripts/test-api.sh
```

测试覆盖：

- ✅ 15+ 测试场景
- ✅ 健康检查和认证
- ✅ CRUD 数据操作
- ✅ 错误处理
- ✅ 性能测试
- ✅ 压力测试
- ✅ 完整性验证

### MySQL 诊断脚本

```bash
# MySQL 连接诊断
./scripts/diagnose-mysql.sh
```

### MySQL 快速设置

```bash
# 自动配置 MySQL
./scripts/setup-mysql.sh 192.168.3.136 3306 root_password
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

完整 API 文档：http://localhost:8001/docs

## 📊 支持的事件类型

- `tokensGenerated` - Token 生成记录
- `chatInteraction` - 聊天交互
- `editInteraction` - 编辑交互
- `editOutcome` - 编辑结果
- `nextEditOutcome` - Next Edit 结果
- `nextEditWithHistory` - 带历史的 Next Edit
- `toolUsage` - 工具使用
- `autocomplete` - 自动补全
- `chatFeedback` - 聊天反馈
- `quickEdit` - 快速编辑

## 🛠️ 开发

### 本地运行

```bash
# 安装依赖
uv sync

# 运行服务
uv run python main.py

# 运行测试
./scripts/test-api.sh
```

### Docker 部署

```bash
# 构建镜像
docker build -t dev-data-service:latest .

# 使用 Docker Compose
docker-compose up -d
docker-compose logs -f
```

## 📁 项目结构

```
dev-data-service/
├── main.py                      # 主应用文件
├── database.py                  # 数据库模块（支持多数据库）
├── pyproject.toml                # Python 项目配置
├── Dockerfile                   # Docker 构建文件
├── docker-compose.yml           # Docker Compose 配置（SQLite）
├── docker-compose.mysql.yml     # Docker Compose 配置（MySQL）
├── .env.example                # 环境变量示例
├── scripts/
│   ├── test-api.sh            # 完整 API 测试套件
│   ├── quick-test.sh          # 快速测试脚本
│   ├── diagnose-mysql.sh       # MySQL 诊断工具
│   ├── setup-mysql.sh          # MySQL 快速设置
│   └── mysql-server-setup.sql  # MySQL 服务器 SQL
└── docs/
    ├── README.md              # 完整文档
    ├── QUICK_REFERENCE.md      # 快速参考
    ├── TOKEN_AUTH_GUIDE.md     # Token 认证指南
    ├── API_TESTING_GUIDE.md    # API 测试指南
    └── MYSQL_TROUBLESHOOTING.md # MySQL 故障排查
```

## 🆘 获取帮助

- 📖 查看 [完整文档](docs/README.md)
- 📋 查看 [快速参考](docs/QUICK_REFERENCE.md)
- 🔧 查看 [API 测试指南](docs/API_TESTING_GUIDE.md)
- 🐛 查看 [故障排查](docs/MYSQL_TROUBLESHOOTING.md)
- 🌐 访问 API 文档：http://localhost:8001/docs

## 环境要求

- Python 3.13+
- Docker & Docker Compose (可选)

## 许可证

Apache-2.0
