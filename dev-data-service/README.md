# Cowork Dev Data Service

一个用于收集和管理 Cowork 开发数据的后端服务。

## 快速开始

```bash
# Docker 部署
docker-compose up -d

# 访问 API 文档
open http://localhost:8001/docs
```

## 文档目录

详细文档请查看 [docs/](docs/) 目录：

- [docs/README.md](docs/README.md) - 完整使用指南
- [docs/TOKEN_AUTH_GUIDE.md](docs/TOKEN_AUTH_GUIDE.md) - Token 认证机制详解

## 主要功能

- 📊 收集 Cowork dev_data 事件
- 🗄️ 支持 SQLite 和 MySQL
- 🔐 Token 认证机制
- 🐳 Docker 部署支持
- 📈 统计和查询功能

## 环境要求

- Python 3.11+
- Docker & Docker Compose (可选)

## 许可证

Apache-2.0
