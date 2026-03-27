#!/bin/bash
# XClaw 配置验证脚本
# 用于检查配置是否准备好推送到 GitHub

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ERRORS=0
WARNINGS=0

echo -e "${BLUE}🔍 XClaw 配置验证脚本${NC}"
echo -e "${BLUE}====================${NC}"
echo ""

# 函数：检查文件存在
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        return 0
    else
        echo -e "${RED}✗${NC} $2 缺失: $1"
        ((ERRORS++))
        return 1
    fi
}

# 函数：检查目录存在
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        return 0
    else
        echo -e "${RED}✗${NC} $2 缺失: $1"
        ((ERRORS++))
        return 1
    fi
}

# 函数：检查 JSON 有效性
check_json() {
    if python3 -m json.tool "$1" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $2 是有效的 JSON"
        return 0
    else
        echo -e "${RED}✗${NC} $2 JSON 格式错误"
        ((ERRORS++))
        return 1
    fi
}

# 1. 检查必要文件
echo -e "${BLUE}[1/5]${NC} 检查必要文件..."
check_file "$SCRIPT_DIR/README.md" "主 README"
check_file "$SCRIPT_DIR/.gitignore" ".gitignore"
check_file "$SCRIPT_DIR/install.sh" "安装脚本"
check_file "$SCRIPT_DIR/1. 卸载旧版本和安装指定版本XClaw/README.md" "安装指南"
check_file "$SCRIPT_DIR/3.skills/README.md" "技能管理文档"
check_file "$SCRIPT_DIR/4.子智能体/README.md" "子智能体文档"
check_file "$SCRIPT_DIR/4.子智能体/agents_config.template.json" "配置模板"
echo ""

# 2. 检查 JSON 文件
echo -e "${BLUE}[2/5]${NC} 检查 JSON 文件格式..."
if [ -f "$SCRIPT_DIR/4.子智能体/agents_config.template.json" ]; then
    check_json "$SCRIPT_DIR/4.子智能体/agents_config.template.json" "agents_config.template.json"
fi
echo ""

# 3. 检查敏感信息
echo -e "${BLUE}[3/5]${NC} 检查敏感信息..."
SENSITIVE_PATTERNS=(
    "api[_-]?key"
    "token"
    "secret"
    "password"
    "maton.*sk"
    "ghp_"
    "tvly-"
)

FOUND_SENSITIVE=0
for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    if grep -riE "$pattern" --include="*.json" --include="*.md" --include="*.sh" "$SCRIPT_DIR" 2>/dev/null | grep -viE "(your_|example|placeholder|template|{{)" | grep -v ".backup" | head -5; then
        FOUND_SENSITIVE=1
    fi
done

if [ $FOUND_SENSITIVE -eq 1 ]; then
    echo -e "${YELLOW}⚠ 发现可能的敏感信息，请检查上述匹配项${NC}"
    ((WARNINGS++))
else
    echo -e "${GREEN}✓${NC} 未发现明显敏感信息"
fi
echo ""

# 4. 检查子智能体工作区
echo -e "${BLUE}[4/5]${NC} 检查子智能体工作区..."
WORKSPACES=(
    "workspace-researcher"
    "workspace-idea"
    "workspace-mentor"
    "workspace-architect"
    "workspace-coder"
    "workspace-writer"
    "workspace-reviewer"
    "workspace-coordinator"
)

for ws in "${WORKSPACES[@]}"; do
    if [ -d "$SCRIPT_DIR/4.子智能体/$ws" ]; then
        echo -e "${GREEN}✓${NC} $ws"
    else
        echo -e "${YELLOW}⚠${NC} $ws 缺失"
        ((WARNINGS++))
    fi
done
echo ""

# 5. 检查文档内容
echo -e "${BLUE}[5/5]${NC} 检查文档内容..."

# 检查 README 是否包含必要章节
if grep -q "快速开始" "$SCRIPT_DIR/README.md" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} README 包含快速开始指南"
else
    echo -e "${YELLOW}⚠${NC} README 可能缺少快速开始指南"
    ((WARNINGS++))
fi

if grep -q "复刻" "$SCRIPT_DIR/README.md" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} README 提到复刻/复制配置"
else
    echo -e "${YELLOW}⚠${NC} README 可能缺少复刻说明"
    ((WARNINGS++))
fi
echo ""

# 总结
echo -e "${BLUE}====================${NC}"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 验证通过！配置已准备好推送到 GitHub${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ 验证通过，但有 $WARNINGS 个警告${NC}"
    echo -e "${YELLOW}  建议处理警告后再推送${NC}"
    exit 0
else
    echo -e "${RED}✗ 验证失败！发现 $ERRORS 个错误${NC}"
    echo -e "${RED}  请修复错误后再推送${NC}"
    exit 1
fi
