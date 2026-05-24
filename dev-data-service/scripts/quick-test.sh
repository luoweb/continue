#!/bin/bash
# Dev Data Service 快速测试脚本
# 用于快速验证服务是否正常工作

set -e

BASE_URL="${1:-http://localhost:8001}"

echo "🔍 Dev Data Service 快速测试"
echo "=============================="
echo ""
echo "测试目标: $BASE_URL"
echo ""

# 1. 健康检查
echo "1️⃣  健康检查..."
if curl -s -f "$BASE_URL/health" > /dev/null 2>&1; then
    echo "   ✅ 服务正常运行"
    curl -s "$BASE_URL/health" | python3 -m json.tool 2>/dev/null | head -5 || echo "   响应: $(curl -s $BASE_URL/health)"
else
    echo "   ❌ 服务未运行"
    exit 1
fi

# 2. 数据库连接
echo ""
echo "2️⃣  数据库连接..."
response=$(curl -s "$BASE_URL/api/v1/stats" 2>/dev/null)
if echo "$response" | grep -q "total_records"; then
    total=$(echo "$response" | grep -o '"total_records":[0-9]*' | cut -d: -f2)
    echo "   ✅ 数据库连接正常"
    echo "   📊 记录总数: $total"
else
    echo "   ⚠️  数据库查询异常"
fi

# 3. 数据提交
echo ""
echo "3️⃣  数据提交测试..."
response=$(curl -s -X POST "$BASE_URL/api/v1/data" \
    -H "Content-Type: application/json" \
    -d '{"name":"quickTest","data":{"test":true},"schema":"0.2.0"}')

if echo "$response" | grep -q '"success":true'; then
    echo "   ✅ 数据提交成功"
else
    echo "   ⚠️  数据提交异常: $response"
fi

# 4. 事件类型
echo ""
echo "4️⃣  事件类型支持..."
response=$(curl -s "$BASE_URL/api/v1/events" 2>/dev/null)
if echo "$response" | grep -q "chatInteraction"; then
    echo "   ✅ 事件类型接口正常"
else
    echo "   ⚠️  事件类型查询异常"
fi

# 5. API 文档
echo ""
echo "5️⃣  API 文档..."
if curl -s -f "$BASE_URL/docs" > /dev/null 2>&1; then
    echo "   ✅ Swagger 文档可访问"
else
    echo "   ⚠️  Swagger 文档无法访问"
fi

echo ""
echo "=============================="
echo "✨ 快速测试完成！"
echo ""
echo "📝 完整测试请运行:"
echo "   ./scripts/test-api.sh $BASE_URL"
echo ""
echo "🌐 API 文档: $BASE_URL/docs"
echo "📊 统计信息: $BASE_URL/api/v1/stats"
echo ""
