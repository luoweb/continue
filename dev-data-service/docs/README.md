# Continue Dev Data Service

一个用于收集和管理 Continue 开发数据的后端服务。

## 功能特性

- 接收并存储 Continue 的 dev_data 事件
- 支持多种数据库：SQLite、MySQL、PostgreSQL
- 支持查询和过滤数据
- 提供统计信息
- 支持数据清理
- API Key 认证（可选）
- Docker 部署支持

## 快速开始

### 方法 1：直接运行 Python

1. 安装依赖：

```bash
pip install -r requirements.txt
```

2. 配置环境变量（可选）：

```bash
cp .env.example .env
# 编辑 .env 文件
```

3. 启动服务：

```bash
python main.py
```

### 方法 2：使用 Docker

#### SQLite (默认)

```bash
# 构建并启动
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

#### MySQL

```bash
# 使用 MySQL 配置启动
docker-compose -f docker-compose.mysql.yml up -d

# 查看日志
docker-compose -f docker-compose.mysql.yml logs -f

# 停止服务
docker-compose -f docker-compose.mysql.yml down
```

#### PostgreSQL

```bash
# 使用 PostgreSQL 配置启动
docker-compose -f docker-compose.postgresql.yml up -d

# 查看日志
docker-compose -f docker-compose.postgresql.yml logs -f

# 停止服务
docker-compose -f docker-compose.postgresql.yml down
```

## 数据库配置

### SQLite (默认)

无需额外配置，默认使用 SQLite。

```env
DB_TYPE=sqlite
DATABASE_PATH=./dev_data.db
```

### MySQL

1. 安装 MySQL 驱动：

```bash
pip install pymysql>=1.1.0
```

2. 配置环境变量：

```env
DB_TYPE=mysql
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=continue_dev_data
DB_CHARSET=utf8mb4
```

3. 创建数据库：

```sql
CREATE DATABASE continue_dev_data CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### PostgreSQL

1. 安装 PostgreSQL 驱动：

```bash
pip install psycopg2-binary>=2.9.9
```

2. 配置环境变量：

```env
DB_TYPE=postgresql
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=continue_dev_data
```

3. 创建数据库：

```sql
CREATE DATABASE continue_dev_data;
```

## 配置

### 环境变量

| 变量          | 描述                                 | 默认值            |
| ------------- | ------------------------------------ | ----------------- |
| HOST          | 服务监听地址                         | 0.0.0.0           |
| PORT          | 服务端口                             | 8001              |
| DB_TYPE       | 数据库类型 (sqlite/mysql/postgresql) | sqlite            |
| DATABASE_PATH | SQLite 数据库路径                    | ./dev_data.db     |
| DB_HOST       | 数据库主机                           | localhost         |
| DB_PORT       | 数据库端口                           | 3306/5432         |
| DB_USER       | 数据库用户名                         | root/postgres     |
| DB_PASSWORD   | 数据库密码                           | -                 |
| DB_NAME       | 数据库名称                           | continue_dev_data |
| DB_CHARSET    | 数据库字符集 (MySQL)                 | utf8mb4           |
| REQUIRE_AUTH  | 是否启用 API Key 认证                | false             |
| API_KEY       | 认证用的 API Key                     | -                 |

### Continue 配置

在您的 Continue `config.yaml` 中添加：

```yaml
data:
  - name: my-dev-data-service
    destination: http://localhost:8001/api/v1/data
    schema: 0.2.0
    level: all
    # 如果启用了认证
    # apiKey: your-api-key
```

## API 端点

### 健康检查

```
GET /health
```

### 提交数据

```
POST /api/v1/data
Content-Type: application/json

{
  "name": "chatInteraction",
  "data": { ... },
  "schema": "0.2.0",
  "level": "all",
  "profileId": "optional-profile-id"
}
```

### 查询数据

```
GET /api/v1/data?event_name=chatInteraction&limit=100
```

查询参数：

- `event_name`: 按事件名称过滤
- `user_id`: 按用户 ID 过滤
- `start_date`: 开始日期（ISO 格式）
- `end_date`: 结束日期（ISO 格式）
- `limit`: 返回记录数（默认 100）
- `offset`: 分页偏移（默认 0）

### 获取统计信息

```
GET /api/v1/stats
```

### 删除旧数据

```
DELETE /api/v1/data/old/90
```

### 获取事件类型列表

```
GET /api/v1/events
```

## API 文档

启动服务后访问：

- Swagger UI: http://localhost:8001/docs
- ReDoc: http://localhost:8001/redoc

## 支持的事件类型

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

## 项目结构

```
dev-data-service/
├── main.py                      # 主应用文件
├── database.py                  # 数据库模块（支持多数据库）
├── pyproject.toml                # Python 项目配置
├── Dockerfile                   # Docker 构建文件
├── docker-compose.yml           # Docker Compose 配置（SQLite）
├── docker-compose.mysql.yml     # Docker Compose 配置（MySQL）
├── .env.example                # 环境变量示例
├── test_api.py                 # API 测试脚本
├── README.md                   # 项目概览
└── docs/
    ├── README.md               # 详细文档（本文件）
    └── TOKEN_AUTH_GUIDE.md     # Token 认证机制详解
```

## 开发

### 运行测试

```bash
# 目前需要手动测试 API
curl http://localhost:8001/health
```

## 许可证

Apache-2.0
