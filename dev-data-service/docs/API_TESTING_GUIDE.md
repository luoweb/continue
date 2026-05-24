# Dev Data Service API 自动化测试指南

## 📋 概述

`test-api.sh` 脚本提供完整的 API 自动化测试，涵盖健康检查、认证、数据操作、性能测试等 15+ 个测试场景。

## 🚀 快速开始

### 1. 运行完整测试

```bash
# 进入项目目录
cd /path/to/dev-data-service

# 添加执行权限
chmod +x scripts/test-api.sh

# 运行测试（使用默认 URL）
./scripts/test-api.sh

# 或指定自定义 URL
./scripts/test-api.sh http://localhost:8001
```

### 2. 查看测试结果

脚本会输出详细的测试结果：

```
========================================
Dev Data Service API 自动化测试
========================================

测试目标: http://localhost:8001
开始时间: 2024-05-24 12:00:00

========================================
1. 检查服务状态
========================================
✓ 服务正在运行

========================================
2. 测试健康检查接口
========================================
✓ 健康检查接口正常 (HTTP 200)
✓ 响应内容正确
...
```

## 📊 测试覆盖范围

### 基础功能测试

| 测试项          | 说明                           |
| --------------- | ------------------------------ |
| ✅ 服务状态检查 | 验证服务是否运行               |
| ✅ 健康检查接口 | GET /health                    |
| ✅ 数据提交接口 | POST /api/v1/data              |
| ✅ 数据查询接口 | GET /api/v1/data               |
| ✅ 统计接口     | GET /api/v1/stats              |
| ✅ 删除接口     | DELETE /api/v1/data/old/{days} |
| ✅ 事件类型接口 | GET /api/v1/events             |

### 认证功能测试

| 测试项           | 说明                         |
| ---------------- | ---------------------------- |
| ✅ Token 创建    | POST /api/v1/tokens          |
| ✅ Token 列表    | GET /api/v1/tokens           |
| ✅ Token 撤销    | DELETE /api/v1/tokens/{name} |
| ✅ 无 Token 访问 | 验证 401 响应                |
| ✅ Token 认证    | 使用 Bearer Token            |

### 数据类型测试

测试各种事件类型的提交：

- `chatInteraction` - 聊天交互
- `tokensGenerated` - Token 生成
- `toolUsage` - 工具使用
- `editInteraction` - 编辑交互

### 高级测试

| 测试项            | 说明               |
| ----------------- | ------------------ |
| 🔧 数据库连接测试 | 验证数据库正常工作 |
| 🔧 错误处理测试   | 测试无效输入和 404 |
| ⚡ 性能测试       | 测量响应时间       |
| 💪 压力测试       | 并发提交数据       |
| 🔍 完整性测试     | 所有端点检查       |

## 🎯 常用测试场景

### 场景 1：首次部署验证

```bash
# 1. 启动服务
docker run -d \
  --name cowork-dev-data-service \
  -p 8001:8001 \
  dev-data-service:latest

# 2. 等待服务启动
sleep 5

# 3. 运行测试
./scripts/test-api.sh
```

### 场景 2：定期健康检查

```bash
# 添加到 crontab
crontab -e

# 每天早上 9 点运行测试
0 9 * * * /path/to/dev-data-service/scripts/test-api.sh >> /var/log/dev-data-service-test.log 2>&1
```

### 场景 3：CI/CD 集成

```bash
# 在 CI/CD 流水线中
./scripts/test-api.sh

# 或指定环境 URL
./scripts/test-api.sh http://production-server:8001

# 检查退出码
if [ $? -eq 0 ]; then
    echo "API 测试通过"
else
    echo "API 测试失败"
    exit 1
fi
```

### 场景 4：调试特定问题

```bash
# 只测试特定功能
# 查看脚本源码，找到对应函数，单独调用
```

## 📝 输出示例

### 成功输出

```
========================================
测试报告
========================================

测试结果统计：
  通过: 45
  失败: 0

总体通过率: 100%

🎉 所有测试通过！
服务运行正常！

完成时间: 2024-05-24 12:00:30
```

### 失败输出

```
========================================
测试报告
========================================

测试结果统计：
  通过: 42
  失败: 3

总体通过率: 93%

⚠️  部分测试失败，请检查上述失败项

========================================
测试报告
========================================

测试结果统计：
  通过: 42
  失败: 3

总体通过率: 93%

⚠️  部分测试失败，请检查上述失败项

完成时间: 2024-05-24 12:00:30
```

## 🔧 高级用法

### 1. 输出到文件

```bash
# 保存完整输出
./scripts/test-api.sh > test-results.txt

# 保存并实时查看
./scripts/test-api.sh | tee test-results.txt

# 只保存失败记录
./scripts/test-api.sh 2>&1 | grep -E "(✗|失败|FAIL)" > failures.txt
```

### 2. 自定义测试 URL

```bash
# 测试本地服务
./scripts/test-api.sh http://localhost:8001

# 测试远程服务
./scripts/test-api.sh http://your-server.com:8001

# 测试 HTTPS
./scripts/test-api.sh https://your-server.com
```

### 3. 与监控集成

```bash
# 发送测试结果到 Slack
./scripts/test-api.sh > /tmp/test.log 2>&1
if [ $? -eq 0 ]; then
    curl -X POST $SLACK_WEBHOOK \
        -d '{"text":"✅ Dev Data Service API 测试通过"}'
else
    curl -X POST $SLACK_WEBHOOK \
        -d '{"text":"❌ Dev Data Service API 测试失败"}'
fi
```

## 🐛 故障排查

### 问题 1: 服务未运行

```
✗ 服务未运行或无法访问
ℹ 请确保服务已启动
```

**解决**：

```bash
# 启动服务
docker run -d \
  --name cowork-dev-data-service \
  -p 8001:8001 \
  dev-data-service:latest

# 验证服务运行
docker ps | grep cowork-dev-data-service
```

### 问题 2: 认证失败

```
✗ Token 创建失败
```

**解决**：

```bash
# 检查服务是否启用认证
curl http://localhost:8001/health | grep auth_enabled

# 如果未启用，设置环境变量
docker run -d \
  --name cowork-dev-data-service \
  -p 8001:8001 \
  -e REQUIRE_AUTH=true \
  dev-data-service:latest
```

### 问题 3: 数据库连接失败

```
✗ 数据库连接异常
```

**解决**：

```bash
# 检查数据库配置
docker logs cowork-dev-data-service

# 使用 SQLite 测试
docker run -d \
  --name cowork-dev-data-service \
  -p 8001:8001 \
  -e DB_TYPE=sqlite \
  dev-data-service:latest
```

## 📈 性能基准

测试脚本包含性能测试，以下是预期的性能指标：

| 测试项   | 良好       | 一般    | 需优化  |
| -------- | ---------- | ------- | ------- |
| 响应时间 | < 100ms    | < 500ms | > 500ms |
| 并发测试 | 100% 成功  | > 90%   | < 90%   |
| 压力测试 | > 98% 成功 | > 90%   | < 90%   |

## 🎨 自定义测试

### 添加新的测试用例

编辑 `scripts/test-api.sh`，找到 `test_custom()` 函数：

```bash
test_custom() {
    print_header "自定义测试"

    # 添加您的测试逻辑
    local response=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
        "${BASE_URL}/your-endpoint")

    if [ "$http_code" = "200" ]; then
        print_success "自定义测试通过"
    else
        print_fail "自定义测试失败"
    fi
}
```

### 禁用特定测试

在脚本开头添加：

```bash
# 禁用压力测试
DISABLE_STRESS_TEST=true

# 禁用性能测试
DISABLE_PERFORMANCE_TEST=true
```

## 📚 相关资源

- [API 文档](http://localhost:8001/docs)
- [MySQL 故障排查](../docs/MYSQL_TROUBLESHOOTING.md)
- [Token 认证指南](../docs/TOKEN_AUTH_GUIDE.md)
- [完整使用文档](../docs/README.md)

## 💡 提示

1. **首次使用**：先运行完整测试套件
2. **调试问题**：查看脚本输出的详细信息
3. **CI/CD**：使用退出码判断成功/失败
4. **监控**：结合 cron 定期检查
5. **压力测试**：谨慎使用，可能影响生产环境

## 🆘 获取帮助

如果测试失败：

1. 查看详细的错误信息
2. 检查服务日志：`docker logs cowork-dev-data-service`
3. 验证配置：检查 `.env` 文件
4. 运行诊断脚本：`./scripts/diagnose-mysql.sh`（如使用 MySQL）

---

**版本**: 1.0.0  
**最后更新**: 2024-05-24  
**维护者**: Dev Data Service Team
