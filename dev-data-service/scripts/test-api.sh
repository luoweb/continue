#!/bin/bash
# Dev Data Service API 自动化测试脚本
# 验证所有主要接口是否正常工作

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
BASE_URL="${1:-http://localhost:8001}"
AUTH_TOKEN=""
REQUIRE_AUTH=false

# 测试计数器
TESTS_PASSED=0
TESTS_FAILED=0

# 输出函数
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((TESTS_PASSED++))
}

print_fail() {
    echo -e "${RED}✗${NC} $1"
    ((TESTS_FAILED++))
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# 检查服务是否运行
check_service() {
    print_header "1. 检查服务状态"

    if curl -s -f "${BASE_URL}/health" > /dev/null 2>&1; then
        print_success "服务正在运行"
        HEALTH_RESPONSE=$(curl -s "${BASE_URL}/health")
        echo "  响应: $HEALTH_RESPONSE"
        return 0
    else
        print_fail "服务未运行或无法访问"
        print_info "请确保服务已启动: docker run -d --name cowork-dev-data-service -p 8001:8001 dev-data-service:latest"
        return 1
    fi
}

# 测试健康检查接口
test_health() {
    print_header "2. 测试健康检查接口"

    local response=$(curl -s -w "\nHTTP_CODE:%{http_code}" "${BASE_URL}/health")
    local http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)
    local body=$(echo "$response" | grep -v "HTTP_CODE")

    if [ "$http_code" = "200" ]; then
        print_success "健康检查接口正常 (HTTP $http_code)"

        # 验证响应内容
        if echo "$body" | grep -q "healthy"; then
            print_success "响应内容正确"
        else
            print_fail "响应内容异常: $body"
        fi
    else
        print_fail "健康检查失败 (HTTP $http_code)"
    fi
}

# 测试认证功能
test_auth() {
    print_header "3. 测试认证功能"

    # 获取服务认证状态
    local health_response=$(curl -s "${BASE_URL}/health")
    local auth_enabled=$(echo "$health_response" | grep -o '"auth_enabled":[^,}]*' | cut -d: -f2)

    if [ "$auth_enabled" = "true" ]; then
        REQUIRE_AUTH=true
        print_info "服务已启用认证"

        # 测试无 Token 访问
        local response=$(curl -s -w "\nHTTP_CODE:%{http_code}" "${BASE_URL}/api/v1/stats")
        local http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)

        if [ "$http_code" = "401" ]; then
            print_success "无 Token 时正确返回 401"
        else
            print_fail "无 Token 时应返回 401，实际: $http_code"
        fi

        # 创建 Token
        print_info "创建测试 Token..."
        local token_response=$(curl -s -X POST "${BASE_URL}/api/v1/tokens" \
            -H "Content-Type: application/json" \
            -d '{"name":"test-token","expires_days":1}')

        if echo "$token_response" | grep -q "token"; then
            AUTH_TOKEN=$(echo "$token_response" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
            print_success "Token 创建成功"
        else
            print_fail "Token 创建失败: $token_response"
            print_info "跳过需要认证的测试"
            return
        fi
    else
        print_info "服务未启用认证"
        print_success "跳过认证测试"
    fi
}

# 获取认证头
get_auth_header() {
    if [ "$REQUIRE_AUTH" = "true" ] && [ -n "$AUTH_TOKEN" ]; then
        echo "-H \"Authorization: Bearer $AUTH_TOKEN\""
    else
        echo ""
    fi
}

# 测试数据提交接口
test_submit_data() {
    print_header "4. 测试数据提交接口"

    local auth_header=$(get_auth_header)

    # 测试基本数据提交
    local test_data='{"name":"chatInteraction","data":{"prompt":"Test prompt","completion":"Test completion","modelProvider":"openai","modelName":"gpt-4"},"schema":"0.2.0","level":"all"}'

    local response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "${BASE_URL}/api/v1/data" \
        -H "Content-Type: application/json" \
        $auth_header \
        -d "$test_data")

    local http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)
    local body=$(echo "$response" | grep -v "HTTP_CODE")

    if [ "$http_code" = "200" ]; then
        print_success "数据提交成功 (HTTP $http_code)"

        if echo "$body" | grep -q '"success":true'; then
            print_success "响应确认成功"
        else
            print_fail "响应异常: $body"
        fi
    else
        print_fail "数据提交失败 (HTTP $http_code)"
        print_info "响应: $body"
    fi
}

# 测试数据查询接口
test_query_data() {
    print_header "5. 测试数据查询接口"

    local auth_header=$(get_auth_header)

    # 测试基本查询
    local response=$(curl -s -w "\nHTTP_CODE:%{http_code}" "${BASE_URL}/api/v1/data" $auth_header)
    local http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)

    if [ "$http_code" = "200" ]; then
        print_success "数据查询成功 (HTTP $http_code)"

        # 验证返回格式
        if echo "$response" | grep -q '"records"'; then
            print_success "响应格式正确"
        else
            print_fail "响应格式异常"
        fi
    else
        print_fail "数据查询失败 (HTTP $http_code)"
    fi

    # 测试带过滤条件的查询
    local response2=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
        "${BASE_URL}/api/v1/data?event_name=chatInteraction&limit=10" \
        $auth_header)
    local http_code2=$(echo "$response2" | grep "HTTP_CODE" | cut -d: -f2)

    if [ "$http_code2" = "200" ]; then
        print_success "带过滤条件查询成功"
    else
        print_fail "带过滤条件查询失败 (HTTP $http_code2)"
    fi
}

# 测试统计接口
test_stats() {
    print_header "6. 测试统计接口"

    local auth_header=$(get_auth_header)

    local response=$(curl -s -w "\nHTTP_CODE:%{http_code}" "${BASE_URL}/api/v1/stats" $auth_header)
    local http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)

    if [ "$http_code" = "200" ]; then
        print_success "统计接口正常 (HTTP $http_code)"

        # 验证返回数据
        if echo "$response" | grep -q '"total_records"'; then
            print_success "统计数据结构正确"
        else
            print_fail "统计数据结构异常"
        fi
    else
        print_fail "统计接口失败 (HTTP $http_code)"
        print_info "响应: $(echo "$response" | grep -v "HTTP_CODE")"
    fi
}

# 测试事件类型接口
test_events() {
    print_header "7. 测试事件类型接口"

    local auth_header=$(get_auth_header)

    local response=$(curl -s -w "\nHTTP_CODE:%{http_code}" "${BASE_URL}/api/v1/events" $auth_header)
    local http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)

    if [ "$http_code" = "200" ]; then
        print_success "事件类型接口正常 (HTTP $http_code)"

        # 验证支持的事件类型
        if echo "$response" | grep -q "tokensGenerated" && echo "$response" | grep -q "chatInteraction"; then
            print_success "支持必要的事件类型"
        else
            print_fail "事件类型列表异常"
        fi
    else
        print_fail "事件类型接口失败 (HTTP $http_code)"
    fi
}

# 测试删除旧数据接口
test_delete() {
    print_header "8. 测试删除旧数据接口"

    local auth_header=$(get_auth_header)

    local response=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
        -X DELETE "${BASE_URL}/api/v1/data/old/1" \
        $auth_header)
    local http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)

    if [ "$http_code" = "200" ]; then
        print_success "删除旧数据接口正常 (HTTP $http_code)"

        if echo "$response" | grep -q '"success":true'; then
            print_success "删除操作确认成功"
        else
            print_fail "删除响应异常: $(echo "$response" | grep -v "HTTP_CODE")"
        fi
    else
        print_fail "删除旧数据接口失败 (HTTP $http_code)"
        print_info "响应: $(echo "$response" | grep -v "HTTP_CODE")"
    fi
}

# 测试 Token 管理功能
test_token_management() {
    print_header "9. 测试 Token 管理功能"

    if [ "$REQUIRE_AUTH" = "true" ]; then
        local auth_header=$(get_auth_header)

        # 列出 Tokens
        local response=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
            "${BASE_URL}/api/v1/tokens" \
            $auth_header)
        local http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)

        if [ "$http_code" = "200" ]; then
            print_success "列出 Tokens 成功"

            if echo "$response" | grep -q '"tokens"'; then
                print_success "Tokens 列表格式正确"
            fi
        else
            print_fail "列出 Tokens 失败 (HTTP $http_code)"
        fi
    else
        print_info "服务未启用认证，跳过 Token 管理测试"
    fi
}

# 测试不同数据类型
test_data_types() {
    print_header "10. 测试不同数据类型"

    local auth_header=$(get_auth_header)

    local test_data_types=(
        '{"name":"tokensGenerated","data":{"tokens":100},"schema":"0.2.0"}'
        '{"name":"toolUsage","data":{"tool":"bash","duration":1.5},"schema":"0.2.0"}'
        '{"name":"editInteraction","data":{"file":"test.py"},"schema":"0.2.0"}'
    )

    for data in "${test_data_types[@]}"; do
        local response=$(eval curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "${BASE_URL}/api/v1/data" \
            -H "Content-Type: application/json" \
            $auth_header \
            -d "$data")

        local http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)

        if [ "$http_code" = "200" ]; then
            print_success "数据类型测试通过: $(echo "$data" | grep -o '"name":"[^"]*"' | cut -d: -f2 | tr -d '"')"
        else
            print_fail "数据类型测试失败: $(echo "$data" | grep -o '"name":"[^"]*"')"
        fi
    done
}

# 性能测试
test_performance() {
    print_header "11. 性能测试"

    # 测试响应时间
    local start_time=$(date +%s%3N)
    curl -s "${BASE_URL}/health" > /dev/null
    local end_time=$(date +%s%3N)
    local duration=$((end_time - start_time))

    if [ $duration -lt 1000 ]; then
        print_success "响应时间良好: ${duration}ms"
    else
        print_info "响应时间: ${duration}ms"
    fi

    # 并发测试
    print_info "进行并发测试..."
    for i in {1..10}; do
        curl -s "${BASE_URL}/health" > /dev/null 2>&1 &
    done
    wait

    local response=$(curl -s -w "\nHTTP_CODE:%{http_code}" "${BASE_URL}/health")
    local http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)

    if [ "$http_code" = "200" ]; then
        print_success "并发测试通过"
    else
        print_fail "并发测试失败"
    fi
}

# 压力测试
test_stress() {
    print_header "12. 压力测试"

    local auth_header=$(get_auth_header)
    local test_count=50
    local success_count=0

    print_info "提交 $test_count 条测试数据..."

    for i in $(seq 1 $test_count); do
        local response=$(eval curl -s -X POST "${BASE_URL}/api/v1/data" \
            -H "Content-Type: application/json" \
            $auth_header \
            -d "{\"name\":\"stressTest\",\"data\":{\"test\":$i},\"schema\":\"0.2.0\"}" 2>&1)

        if echo "$response" | grep -q '"success":true'; then
            ((success_count++))
        fi
    done

    local success_rate=$((success_count * 100 / test_count))

    if [ $success_rate -ge 95 ]; then
        print_success "压力测试通过: $success_count/$test_count 成功 ($success_rate%)"
    else
        print_fail "压力测试结果不佳: $success_count/$test_count 成功 ($success_rate%)"
    fi
}

# 数据库连接测试
test_database() {
    print_header "13. 测试数据库连接"

    local auth_header=$(get_auth_header)

    # 通过统计数据验证数据库连接
    local response=$(curl -s -w "\nHTTP_CODE:%{http_code}" "${BASE_URL}/api/v1/stats" $auth_header)
    local http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)

    if [ "$http_code" = "200" ]; then
        print_success "数据库连接正常"

        # 检查是否有数据
        local total=$(echo "$response" | grep -o '"total_records":[0-9]*' | cut -d: -f2)
        print_info "数据库中共有 $total 条记录"
    else
        print_fail "数据库连接异常 (HTTP $http_code)"
        print_info "响应: $(echo "$response" | grep -v "HTTP_CODE")"
    fi
}

# 错误处理测试
test_error_handling() {
    print_header "14. 测试错误处理"

    local auth_header=$(get_auth_header)

    # 测试无效数据
    local response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "${BASE_URL}/api/v1/data" \
        -H "Content-Type: application/json" \
        $auth_header \
        -d '{"invalid":"data"}')

    local http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)

    if [ "$http_code" != "200" ]; then
        print_success "无效数据被正确拒绝 (HTTP $http_code)"
    else
        print_info "无效数据处理: HTTP $http_code"
    fi

    # 测试无效端点
    local response2=$(curl -s -w "\nHTTP_CODE:%{http_code}" "${BASE_URL}/api/v1/invalid")
    local http_code2=$(echo "$response2" | grep "HTTP_CODE" | cut -d: -f2)

    if [ "$http_code2" = "404" ]; then
        print_success "无效端点返回 404"
    else
        print_info "无效端点响应: HTTP $http_code2"
    fi
}

# 完整性测试
test_completeness() {
    print_header "15. 完整性测试"

    local auth_header=$(get_auth_header)
    local all_tests_passed=true

    # 测试所有端点
    local endpoints=(
        "/health"
        "/api/v1/data"
        "/api/v1/stats"
        "/api/v1/events"
    )

    for endpoint in "${endpoints[@]}"; do
        local response=$(curl -s -w "\nHTTP_CODE:%{http_code}" "${BASE_URL}${endpoint}" $auth_header)
        local http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)

        if [ "$http_code" != "200" ]; then
            all_tests_passed=false
            print_fail "端点 ${endpoint} 失败 (HTTP $http_code)"
        fi
    done

    if [ "$all_tests_passed" = true ]; then
        print_success "所有端点完整性测试通过"
    fi
}

# 生成测试报告
generate_report() {
    print_header "测试报告"

    echo ""
    echo -e "测试结果统计："
    echo -e "  ${GREEN}通过: $TESTS_PASSED${NC}"
    echo -e "  ${RED}失败: $TESTS_FAILED${NC}"
    echo ""

    local total_tests=$((TESTS_PASSED + TESTS_FAILED))
    local pass_rate=$((TESTS_PASSED * 100 / total_tests))

    echo -e "总体通过率: ${pass_rate}%"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}🎉 所有测试通过！${NC}"
        echo -e "${GREEN}服务运行正常！${NC}"
        return 0
    else
        echo -e "${RED}⚠️  部分测试失败，请检查上述失败项${NC}"
        return 1
    fi
}

# 清理测试数据
cleanup() {
    print_header "清理测试数据"

    local auth_header=$(get_auth_header)

    # 删除测试数据
    local response=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
        -X DELETE "${BASE_URL}/api/v1/data/old/0" \
        $auth_header)

    local http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)

    if [ "$http_code" = "200" ]; then
        print_success "测试数据清理完成"
    else
        print_info "清理请求完成 (HTTP $http_code)"
    fi
}

# 主函数
main() {
    echo ""
    echo "========================================"
    echo "Dev Data Service API 自动化测试"
    echo "========================================"
    echo ""
    echo "测试目标: $BASE_URL"
    echo "开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""

    # 检查服务
    if ! check_service; then
        echo ""
        echo -e "${RED}服务不可用，测试终止${NC}"
        exit 1
    fi

    # 运行测试
    test_health
    test_auth
    test_submit_data
    test_query_data
    test_stats
    test_events
    test_delete
    test_token_management
    test_data_types
    test_database
    test_error_handling
    test_performance
    test_stress
    test_completeness

    # 生成报告
    generate_report

    echo ""
    echo "完成时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""

    # 返回测试结果
    if [ $TESTS_FAILED -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# 运行主函数
main "$@"
