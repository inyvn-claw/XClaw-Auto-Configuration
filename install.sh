#!/bin/bash
# XClaw 一键安装脚本
# 用于复刻 https://github.com/your-username/XClaw-Config 配置

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🦞 XClaw 配置一键安装脚本${NC}"
echo -e "${BLUE}========================${NC}"
echo ""

# 函数：打印步骤
step() {
    echo -e "${BLUE}[步骤 $1/$2]${NC} $3"
}

# 函数：检查命令
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}✗ 未找到命令: $1${NC}"
        return 1
    fi
    echo -e "${GREEN}✓${NC} $1 已安装"
    return 0
}

# 步骤 0：检查前置条件
echo -e "${YELLOW}检查前置条件...${NC}"
if ! check_command "openclaw"; then
    echo -e "${RED}请先安装 OpenClaw:${NC}"
    echo "  npm install -g openclaw@2026.3.13"
    echo ""
    echo "详细步骤请参考: 1. 卸载旧版本和安装指定版本XClaw/README.md"
    exit 1
fi

if ! check_command "clawhub"; then
    echo -e "${YELLOW}⚠ clawhub 未找到，将使用 npx 运行${NC}"
    CLAWHUB_CMD="npx -y clawhub@latest"
else
    CLAWHUB_CMD="clawhub"
fi

if ! check_command "git"; then
    echo -e "${RED}✗ 请先安装 Git${NC}"
    exit 1
fi

echo ""

# 步骤 1：复制子智能体工作区配置
step 1 5 "复制子智能体工作区配置"
if [ ! -d "$HOME/.openclaw" ]; then
    echo -e "${YELLOW}创建 ~/.openclaw 目录${NC}"
    mkdir -p "$HOME/.openclaw"
fi

for workspace in "$SCRIPT_DIR"/4.子智能体/workspace-*; do
    if [ -d "$workspace" ]; then
        name=$(basename "$workspace")
        if [ -d "$HOME/.openclaw/$name" ]; then
            echo -e "${YELLOW}  备份现有 $name${NC}"
            mv "$HOME/.openclaw/$name" "$HOME/.openclaw/${name}.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        echo "  复制 $name"
        cp -r "$workspace" "$HOME/.openclaw/"
    fi
done
echo -e "${GREEN}✓ 工作区配置复制完成${NC}"
echo ""

# 步骤 2：更新 openclaw.json
step 2 5 "更新 OpenClaw 主配置"
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
    echo -e "${YELLOW}  备份现有配置${NC}"
    cp "$HOME/.openclaw/openclaw.json" "$HOME/.openclaw/openclaw.json.backup.$(date +%Y%m%d_%H%M%S)"
fi

# 从模板生成配置
if [ -f "$SCRIPT_DIR/4.子智能体/agents_config.template.json" ]; then
    # 使用 sed 替换 {{HOME}} 为实际 home 目录
    sed "s|{{HOME}}|$HOME|g" "$SCRIPT_DIR/4.子智能体/agents_config.template.json" > "$HOME/.openclaw/agents_config.json"
    echo -e "${GREEN}✓ 配置生成完成${NC}"
    echo -e "${YELLOW}  请手动将 agents 配置合并到 ~/.openclaw/openclaw.json${NC}"
    echo "  参考: 4.子智能体/agents_config.json"
else
    echo -e "${YELLOW}  未找到配置模板，请手动复制配置${NC}"
fi
echo ""

# 步骤 3：安装 LabClaw 技能
step 3 5 "安装 LabClaw 技能 (240个)"
if [ -d "$HOME/.openclaw/skills/LabClaw" ]; then
    echo -e "${YELLOW}  LabClaw 已存在，跳过克隆${NC}"
else
    echo "  克隆 LabClaw 仓库..."
    cd "$HOME/.openclaw/skills"
    git clone https://github.com/wu-yc/LabClaw.git
    cp -r LabClaw/skills/* .
    echo -e "${GREEN}✓ LabClaw 安装完成${NC}"
fi
echo ""

# 步骤 4：安装 ClawHub 核心技能
step 4 5 "安装 ClawHub 核心技能"
SKILLS=(
    "arxiv-watcher"
    "literature-review"
    "perplexity"
    "senior-architect"
    "backend-patterns"
    "test-runner"
    "docker-essentials"
    "wandb-monitor"
    "debug-pro"
    "ai-pdf-builder"
    "typetex"
    "chart-image"
    "nano-pdf"
    "project-context-sync"
    "prompt-log"
    "git-essentials"
    "get-tldr"
    "claude-optimised"
    "god-mode"
    "api-gateway"
)

for skill in "${SKILLS[@]}"; do
    echo -n "  安装 $skill ... "
    if $CLAWHUB_CMD install "$skill" --force 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}⚠ 失败或已安装${NC}"
    fi
    # 避免触发速率限制
    sleep 1
done
echo -e "${GREEN}✓ ClawHub 技能安装完成${NC}"
echo ""

# 步骤 5：完成提示
step 5 5 "安装完成"
echo ""
echo -e "${GREEN}🎉 XClaw 配置安装完成！${NC}"
echo ""
echo -e "${BLUE}下一步操作：${NC}"
echo ""
echo "1. 配置 API Key（如需要）:"
echo "   export MATON_API_KEY='your-maton-api-key'"
echo "   export GITHUB_TOKEN='your-github-token'"
echo ""
echo "2. 重启 OpenClaw:"
echo "   openclaw gateway restart"
echo ""
echo "3. 验证安装:"
echo "   openclaw status"
echo "   clawhub list"
echo ""
echo "4. 测试子智能体:"
echo "   发送消息: '启动 coordinator 帮我规划论文写作'"
echo ""
echo -e "${YELLOW}📚 详细文档请参考各目录下的 README.md${NC}"
echo ""
