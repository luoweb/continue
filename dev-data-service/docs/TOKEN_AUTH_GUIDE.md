# Token 校验机制使用指南

## 概述

Dev Data Service 实现了完整的 Token 校验机制，包括：

- 🔐 Token 生成和管理
- ⏰ Token 过期时间验证
- 📊 请求次数限制
- 🔒 Token 撤销功能
- 🛡️ 安全的 Token 存储（使用 SHA256 哈希）

## 快速开始

### 1. 启用认证

在启动服务时设置环境变量：

```bash
# 使用 Docker
docker run -d -p 8001:8001 \
  -e REQUIRE_AUTH=true \
  dev-data-service:latest

# 或使用 docker-compose.yml
# 设置 REQUIRE_AUTH=true
```

### 2. 创建第一个 Token

```bash
curl -X POST http://localhost:8001/api/v1/tokens \
  -H "Content-Type: application/json" \
  -d '{
    "name": "production",
    "expires_days": 30,
    "max_requests": null
  }'
```

**响应示例：**

```json
{
  "token": "6LfIJzNPHTSIgIXc28KTh_afzl8tJarC79CFjwMCQBA",
  "name": "production",
  "expires_at": "2026-06-23T08:29:49.786250",
  "max_requests": null,
  "message": "Save this token securely. It will not be shown again."
}
```

### 3. 使用 Token

在请求头中包含 Token：

```bash
curl -X POST http://localhost:8001/api/v1/data \
  -H "Authorization: Bearer 6LfIJzNPHTSIgIXc28KTh_afzl8tJarC79CFjwMCQBA" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "chatInteraction",
    "data": {"prompt": "Hello"},
    "schema": "0.2.0"
  }'
```

## Token 管理 API

### 创建 Token

**端点：** `POST /api/v1/tokens`

**请求体：**

```json
{
  "name": "token_name",
  "expires_days": 30,
  "max_requests": null
}
```

**参数说明：**

- `name`: Token 名称，用于标识（必需）
- `expires_days`: 过期天数，1-365（默认：30）
- `max_requests`: 最大请求次数，无限制为 null（可选）

**示例 - 创建有限制次数的 Token：**

```bash
curl -X POST http://localhost:8001/api/v1/tokens \
  -H "Content-Type: application/json" \
  -d '{
    "name": "test-limited",
    "expires_days": 1,
    "max_requests": 100
  }'
```

### 列出所有 Tokens

**端点：** `GET /api/v1/tokens`

**响应示例：**

```json
{
  "tokens": [
    {
      "name": "production",
      "created_at": "2026-05-24T08:29:49.786223",
      "expires_at": "2026-06-23T08:29:49.786250",
      "max_requests": null,
      "request_count": 42,
      "is_active": true
    },
    {
      "name": "test-limited",
      "created_at": "2026-05-24T08:30:27.886866",
      "expires_at": "2026-05-25T08:30:27.886877",
      "max_requests": 100,
      "request_count": 15,
      "is_active": true
    }
  ],
  "total": 2
}
```

### 撤销 Token

**端点：** `DELETE /api/v1/tokens/{token_name}`

```bash
curl -X DELETE http://localhost:8001/api/v1/tokens/test-limited \
  -H "Authorization: Bearer YOUR_CURRENT_TOKEN"
```

**响应：**

```json
{
  "success": true,
  "message": "Token 'test-limited' has been revoked"
}
```

## Token 验证规则

1. **Token 格式验证**
   - 必须使用 `Authorization: Bearer <token>` 格式
   - Token 必须是有效的 URL-safe 字符串

2. **Token 存在性验证**
   - Token 必须存在于系统中
   - 使用 SHA256 哈希存储，确保安全性

3. **Token 状态验证**
   - Token 必须处于激活状态（`is_active: true`）
   - 撤销的 Token 无法使用

4. **过期时间验证**
   - Token 必须在有效期内
   - 过期后自动拒绝访问

5. **请求次数限制**
   - 如果设置了 `max_requests`，则不能超过限制
   - 系统会跟踪每个 Token 的请求次数

## 错误响应

### 401 Unauthorized

```json
{
  "detail": "Authorization header is required"
}
```

可能的错误信息：

- `"Authorization header is required"` - 未提供认证头
- `"Invalid authorization header format. Use: Bearer <token>"` - 格式错误
- `"Invalid token"` - Token 不存在
- `"Token has been revoked"` - Token 已撤销
- `"Token has expired"` - Token 已过期
- `"Token request limit exceeded"` - 请求次数超限

### 403 Forbidden

```json
{
  "detail": "Authentication is disabled. Set REQUIRE_AUTH=true to enable token management."
}
```

当 `REQUIRE_AUTH=false` 时访问 Token 管理接口会返回此错误。

## 最佳实践

### 1. Token 命名规范

使用有意义的名称：

- `production` - 生产环境
- `development` - 开发环境
- `testing` - 测试环境
- `client-xxx` - 特定客户端

### 2. Token 过期策略

根据用途设置合适的过期时间：

| 用途       | 建议过期时间 |
| ---------- | ------------ |
| 长期服务   | 90-365 天    |
| 短期测试   | 1-7 天       |
| 临时访问   | 1-24 小时    |
| CI/CD 集成 | 30-90 天     |

### 3. 请求次数限制

建议为不同用途设置限制：

| 用途     | 建议限制       |
| -------- | -------------- |
| 生产服务 | 无限制（null） |
| 测试环境 | 1000-10000     |
| 临时访问 | 10-100         |
| 低频使用 | 50-500         |

### 4. Token 安全

- ✅ 生成后立即保存 Token（只会显示一次）
- ✅ 使用 HTTPS 传输 Token
- ✅ 不要将 Token 提交到代码仓库
- ✅ 定期轮换 Token
- ✅ 及时撤销不再使用的 Token

### 5. 环境变量配置

```bash
# 启用认证
REQUIRE_AUTH=true

# 监听地址
HOST=0.0.0.0
PORT=8001
```

## 测试示例

### 完整测试流程

```bash
#!/bin/bash

BASE_URL="http://localhost:8001"

echo "1. 创建 Token..."
RESPONSE=$(curl -s -X POST $BASE_URL/api/v1/tokens \
  -H "Content-Type: application/json" \
  -d '{"name":"test","expires_days":1,"max_requests":5}')

TOKEN=$(echo $RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
echo "Token: $TOKEN"

echo -e "\n2. 使用 Token 提交数据（允许5次）..."
for i in {1..6}; do
  RESP=$(curl -s -w "\n%{http_code}" -X POST $BASE_URL/api/v1/data \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"name":"test","data":{},"schema":"0.2.0"}')

  HTTP_CODE=$(echo "$RESP" | tail -1)
  echo "Request $i: HTTP $HTTP_CODE"

  if [ "$HTTP_CODE" = "401" ]; then
    echo "Token limit reached!"
    break
  fi
done

echo -e "\n3. 列出所有 Tokens..."
curl -s $BASE_URL/api/v1/tokens \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool

echo -e "\n4. 尝试使用无效 Token..."
curl -s $BASE_URL/api/v1/stats \
  -H "Authorization: Bearer invalid_token" | python3 -m json.tool
```

## 与 Cowork 集成

在 Cowork 的 `config.yaml` 中配置：

```yaml
data:
  - name: my-dev-data-service
    destination: http://your-server:8001/api/v1/data
    schema: 0.2.0
    level: all
```

服务会自动处理 Token 认证。

## 故障排查

### 问题 1: Token 认证失败

**症状：** 所有请求返回 401

**检查步骤：**

1. 确认 `REQUIRE_AUTH=true`
2. 检查 Token 是否过期
3. 确认 Token 未被撤销
4. 验证请求次数未超限

### 问题 2: 无法创建 Token

**症状：** 返回 403 Forbidden

**原因：** `REQUIRE_AUTH=false`

**解决：** 设置 `REQUIRE_AUTH=true`

### 问题 3: Token 被拒绝

**症状：** "Token has been revoked"

**原因：** Token 已被撤销

**解决：** 创建新的 Token

## API 端点一览

| 方法   | 端点                    | 说明           | 需要认证 |
| ------ | ----------------------- | -------------- | -------- |
| GET    | /health                 | 健康检查       | 否       |
| POST   | /api/v1/tokens          | 创建 Token     | 否\*     |
| GET    | /api/v1/tokens          | 列出 Tokens    | 是       |
| DELETE | /api/v1/tokens/{name}   | 撤销 Token     | 是       |
| POST   | /api/v1/data            | 提交数据       | 是       |
| GET    | /api/v1/data            | 查询数据       | 是       |
| GET    | /api/v1/stats           | 统计数据       | 是       |
| DELETE | /api/v1/data/old/{days} | 删除旧数据     | 是       |
| GET    | /api/v1/events          | 支持的事件类型 | 是       |

\*创建 Token 不需要认证，但只有在 `REQUIRE_AUTH=true` 时才可访问

## 总结

Dev Data Service 的 Token 校验机制提供了企业级的安全特性：

- 🔐 **安全存储** - 使用 SHA256 哈希存储 Token
- ⏰ **过期控制** - 支持自定义过期时间
- 📊 **请求限制** - 可选的请求次数限制
- 🔒 **灵活撤销** - 随时撤销不再使用的 Token
- 🎯 **详细追踪** - 记录每个 Token 的使用情况

根据您的需求选择合适的配置，既能保证安全性，又能提供便利的访问体验！
