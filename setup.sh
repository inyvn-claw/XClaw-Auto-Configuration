#!/bin/bash
# XClaw 交互式一键配置脚本
# 自动完成 1-4 部分配置，并引导输入 API Key

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# API Keys（将在交互中收集）
MATON_API_KEY=""
TAVILY_API_KEY=""
GITHUB_TOKEN=""
GITHUB_USERNAME=""

# 统计
SKILLS_INSTALLED=0
SKILLS_FAILED=0

echo -e "${CYAN}"
cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║              🦞 XClaw 交互式一键配置脚本                     ║
║                                                              ║
║   自动完成：OpenClaw 安装 → 子智能体配置 → 技能安装        ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# 函数：打印分隔线
print_line() {
    echo -e "${BLUE}────────────────────────────────────────${NC}"
}

# 函数：打印步骤标题
step_title() {
    echo ""
    print_line
    echo -e "${BLUE}[步骤 $1/6]${NC} ${YELLOW}$2${NC}"
    print_line
    echo ""
}

# 函数：确认继续
confirm_continue() {
    echo ""
    read -p "按 Enter 继续，或输入 'skip' 跳过此步骤: " choice
    if [[ "$choice" == "skip" ]]; then
        return 1
    fi
    return 0
}

# 函数：安装单个技能
install_skill() {
    local skill=$1
    local cmd=${2:-"clawhub"}
    
    echo -n "  安装 $skill ... "
    if $cmd install "$skill" --force >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        ((SKILLS_INSTALLED++))
        return 0
    else
        echo -e "${YELLOW}⚠ 失败${NC}"
        ((SKILLS_FAILED++))
        return 1
    fi
}

# 步骤 0：环境检查
echo ""
echo -e "${CYAN}🔍 环境检查${NC}"
echo ""

# 检查 Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    echo -e "${GREEN}✓${NC} Node.js 已安装: $NODE_VERSION"
else
    echo -e "${RED}✗${NC} Node.js 未安装"
    echo "  请先安装 Node.js: https://nodejs.org/"
    exit 1
fi

# 检查 npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm -v)
    echo -e "${GREEN}✓${NC} npm 已安装: $NPM_VERSION"
else
    echo -e "${RED}✗${NC} npm 未安装"
    exit 1
fi

# 检查 Git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | head -1)
    echo -e "${GREEN}✓${NC} Git 已安装: $GIT_VERSION"
else
    echo -e "${RED}✗${NC} Git 未安装"
    exit 1
fi

# 检查 OpenClaw
if command -v openclaw &> /dev/null; then
    OPENCLAW_VERSION=$(openclaw --version 2>&1 | head -1)
    echo -e "${GREEN}✓${NC} OpenClaw 已安装: $OPENCLAW_VERSION"
    OPENCLAW_INSTALLED=true
else
    echo -e "${YELLOW}⚠${NC} OpenClaw 未安装"
    OPENCLAW_INSTALLED=false
fi

# 检查 clawhub
if command -v clawhub &> /dev/null; then
    echo -e "${GREEN}✓${NC} clawhub 已安装"
    CLAWHUB_CMD="clawhub"
else
    echo -e "${YELLOW}⚠${NC} clawhub 未安装，将使用 npx"
    CLAWHUB_CMD="npx -y clawhub@latest"
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# 步骤 1：安装 OpenClaw
# ═══════════════════════════════════════════════════════════════
step_title 1 "安装 OpenClaw"

if [ "$OPENCLAW_INSTALLED" = true ]; then
    echo -e "${GREEN}✓${NC} OpenClaw 已安装，跳过此步骤"
    echo ""
    read -p "是否要重新安装/更新到指定版本 2026.3.13? [y/N]: " reinstall
    if [[ "$reinstall" =~ ^[Yy]$ ]]; then
        OPENCLAW_INSTALLED=false
    fi
fi

if [ "$OPENCLAW_INSTALLED" = false ]; then
    echo "将执行以下操作："
    echo "  1. 安装 OpenClaw 2026.3.13"
    echo "  2. 运行 onboard 初始化"
    echo ""
    
    if confirm_continue; then
        echo -e "${BLUE}正在安装 OpenClaw...${NC}"
        npm install -g openclaw@2026.3.13
        
        echo ""
        echo -e "${BLUE}初始化 OpenClaw...${NC}"
        echo -e "${YELLOW}请按照提示完成初始化配置${NC}"
        openclaw onboard --install-daemon
        
        echo ""
        echo -e "${GREEN}✓${NC} OpenClaw 安装完成"
    else
        echo -e "${YELLOW}跳过 OpenClaw 安装${NC}"
    fi
else
    echo -e "${GREEN}✓${NC} 使用现有 OpenClaw 安装"
fi

# ═══════════════════════════════════════════════════════════════
# 步骤 2：安装飞书插件（可选）
# ═══════════════════════════════════════════════════════════════
step_title 2 "安装飞书插件（可选）"

echo "如果您使用飞书（Lark/Feishu）作为消息渠道，可以安装飞书插件。"
echo ""
read -p "是否安装飞书插件? [y/N]: " install_feishu

if [[ "$install_feishu" =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}正在安装飞书插件...${NC}"
    npx -y @larksuite/openclaw-lark@2026.3.17 install
    echo -e "${GREEN}✓${NC} 飞书插件安装完成"
    
    echo ""
    echo -e "${YELLOW}注意：飞书插件需要配置 App ID 和 App Secret${NC}"
    echo "  1. 访问飞书开放平台: https://open.feishu.cn/"
    echo "  2. 创建企业自建应用"
    echo "  3. 获取 App ID 和 App Secret"
    echo "  4. 编辑 ~/.openclaw/openclaw.json 添加配置"
else
    echo -e "${YELLOW}跳过飞书插件安装${NC}"
fi

# ═══════════════════════════════════════════════════════════════
# 步骤 3：配置子智能体
# ═══════════════════════════════════════════════════════════════
step_title 3 "配置 8 个科研子智能体"

echo "将配置以下子智能体："
echo "  1. researcher   - 文献调研员"
echo "  2. idea         - 创意生成器"
echo "  3. mentor       - 导师审核员"
echo "  4. architect    - 架构设计师"
echo "  5. coder        - 实验工程师"
echo "  6. writer       - 论文撰写员"
echo "  7. reviewer     - 论文审稿人"
echo "  8. coordinator  - 科研主管"
echo ""

if confirm_continue; then
    # 检查并创建 .openclaw 目录
    if [ ! -d "$HOME/.openclaw" ]; then
        mkdir -p "$HOME/.openclaw"
    fi
    
    # 备份现有配置
    if [ -f "$HOME/.openclaw/openclaw.json" ]; then
        BACKUP_FILE="$HOME/.openclaw/openclaw.json.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$HOME/.openclaw/openclaw.json" "$BACKUP_FILE"
        echo -e "${YELLOW}已备份现有配置到: $BACKUP_FILE${NC}"
    fi
    
    # 复制子智能体工作区
    echo "复制子智能体工作区..."
    for workspace in "$SCRIPT_DIR/4.子智能体/workspace-"*; do
        if [ -d "$workspace" ]; then
            name=$(basename "$workspace")
            target="$HOME/.openclaw/$name"
            
            if [ -d "$target" ]; then
                echo "  备份现有 $name"
                mv "$target" "${target}.backup.$(date +%Y%m%d_%H%M%S)"
            fi
            
            echo "  复制 $name"
            cp -r "$workspace" "$target"
        fi
    done
    
    # 生成配置文件
    echo ""
    echo "生成 OpenClaw 配置文件..."
    if [ -f "$SCRIPT_DIR/4.子智能体/agents_config.template.json" ]; then
        sed "s|{{HOME}}|$HOME|g" "$SCRIPT_DIR/4.子智能体/agents_config.template.json" > "$HOME/.openclaw/agents_config.json"
        echo -e "${GREEN}✓${NC} 配置文件已生成: ~/.openclaw/agents_config.json"
        echo ""
        echo -e "${YELLOW}重要：请手动将 agents 配置合并到 ~/.openclaw/openclaw.json${NC}"
        echo "  可以参考: ~/.openclaw/agents_config.json"
    else
        echo -e "${YELLOW}⚠ 未找到配置模板，请手动复制配置${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}✓${NC} 子智能体配置完成"
else
    echo -e "${YELLOW}跳过子智能体配置${NC}"
fi

# ═══════════════════════════════════════════════════════════════
# 步骤 4：安装技能
# ═══════════════════════════════════════════════════════════════
step_title 4 "安装技能"

echo "将安装以下技能："
echo ""
echo -e "${CYAN}LabClaw (240个生物医学技能):${NC}"
echo "  - bio/ (86个)        - 生物学和生命科学"
echo "  - general/ (54个)    - 通用数据科学"
echo "  - literature/ (33个) - 文献检索"
echo "  - med/ (22个)        - 医学临床"
echo "  - pharma/ (36个)     - 药物研发"
echo "  - vision/ (5个)      - 视觉处理"
echo ""
echo -e "${CYAN}ClawHub 核心技能 (20+个):${NC}"
echo "  - arxiv-watcher, literature-review, perplexity"
echo "  - senior-architect, backend-patterns"
echo "  - test-runner, docker-essentials, wandb-monitor"
echo "  - ai-pdf-builder, typetex, chart-image"
echo "  - git-essentials, god-mode, api-gateway"
echo ""

if confirm_continue; then
    # 安装 LabClaw
    echo -e "${BLUE}安装 LabClaw...${NC}"
    if [ ! -d "$HOME/.openclaw/skills" ]; then
        mkdir -p "$HOME/.openclaw/skills"
    fi
    
    cd "$HOME/.openclaw/skills"
    
    if [ -d "LabClaw" ]; then
        echo -e "${YELLOW}LabClaw 已存在，更新中...${NC}"
        cd LabClaw && git pull && cd ..
    else
        echo "克隆 LabClaw 仓库..."
        git clone https://github.com/wu-yc/LabClaw.git
    fi
    
    echo "复制技能文件..."
    cp -r LabClaw/skills/* . 2>/dev/null || true
    echo -e "${GREEN}✓${NC} LabClaw 安装完成"
    
    # 安装 ClawHub 技能
    echo ""
    echo -e "${BLUE}安装 ClawHub 核心技能...${NC}"
    
    CLAWHUB_SKILLS=(
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
    
    for skill in "${CLAWHUB_SKILLS[@]}"; do
        install_skill "$skill" "$CLAWHUB_CMD"
        sleep 0.5  # 避免触发速率限制
    done
    
    echo ""
    echo -e "${GREEN}✓${NC} 技能安装完成"
    echo "  成功: $SKILLS_INSTALLED 个"
    echo "  失败: $SKILLS_FAILED 个"
else
    echo -e "${YELLOW}跳过技能安装${NC}"
fi

# ═══════════════════════════════════════════════════════════════
# 步骤 5：配置 API Key
# ═══════════════════════════════════════════════════════════════
step_title 5 "配置 API Key（可选但推荐）"

echo -e "${CYAN}以下 API Key 用于扩展功能，您可以选择性配置：${NC}"
echo ""

# Maton API Key
print_line
echo -e "${CYAN}1. Maton API Gateway${NC}"
echo "   用途: 发送邮件、连接 Google/Microsoft/Notion/Slack 等 100+ 服务"
echo "   获取: https://maton.ai/settings"
echo ""
read -p "是否配置 Maton API Key? [y/N]: " config_maton
if [[ "$config_maton" =~ ^[Yy]$ ]]; then
    read -s -p "请输入 Maton API Key: " MATON_API_KEY
    echo ""
    
    # 添加到 shell 配置
    if [ -f "$HOME/.bashrc" ]; then
        # 删除旧配置
        sed -i '/MATON_API_KEY/d' "$HOME/.bashrc"
        echo "" >> "$HOME/.bashrc"
        echo "# Maton API Gateway" >> "$HOME/.bashrc"
        echo "export MATON_API_KEY=\"$MATON_API_KEY\"" >> "$HOME/.bashrc"
    fi
    
    if [ -f "$HOME/.zshrc" ]; then
        sed -i '/MATON_API_KEY/d' "$HOME/.zshrc"
        echo "" >> "$HOME/.zshrc"
        echo "# Maton API Gateway" >> "$HOME/.zshrc"
        echo "export MATON_API_KEY=\"$MATON_API_KEY\"" >> "$HOME/.zshrc"
    fi
    
    # 添加到 OpenClaw 配置
    if [ -f "$HOME/.openclaw/openclaw.json" ]; then
        # 创建临时文件更新 JSON
        python3 <> PYCODE
import json
import sys

with open('$HOME/.openclaw/openclaw.json', 'r') as f:
    config = json.load(f)

if 'env' not in config:
    config['env'] = {}
config['env']['MATON_API_KEY'] = '$MATON_API_KEY'

with open('$HOME/.openclaw/openclaw.json', 'w') as f:
    json.dump(config, f, indent=2)

print("已更新 openclaw.json")
PYCODE
    fi
    
    echo -e "${GREEN}✓${NC} Maton API Key 已配置"
    echo "  已添加到 ~/.bashrc 和 ~/.zshrc"
    echo "  已添加到 OpenClaw 配置"
fi

# Tavily API Key
print_line
echo ""
echo -e "${CYAN}2. Tavily API (AI 搜索)${NC}"
echo "   用途: 高质量的 AI 网络搜索"
echo "   获取: https://app.tavily.com/"
echo ""
read -p "是否配置 Tavily API Key? [y/N]: " config_tavily
if [[ "$config_tavily" =~ ^[Yy]$ ]]; then
    read -s -p "请输入 Tavily API Key: " TAVILY_API_KEY
    echo ""
    
    # 创建 .env 文件
    if [ ! -f "$HOME/.openclaw/.env" ]; then
        touch "$HOME/.openclaw/.env"
    fi
    
    # 删除旧配置
    sed -i '/TAVILY_API_KEY/d' "$HOME/.openclaw/.env"
    echo "TAVILY_API_KEY=$TAVILY_API_KEY" >> "$HOME/.openclaw/.env"
    
    echo -e "${GREEN}✓${NC} Tavily API Key 已配置"
    echo "  已添加到 ~/.openclaw/.env"
fi

# GitHub Token
print_line
echo ""
echo -e "${CYAN}3. GitHub Token${NC}"
echo "   用途: 管理 GitHub 仓库、Issue、PR"
echo "   获取: https://github.com/settings/tokens"
echo ""
read -p "是否配置 GitHub Token? [y/N]: " config_github
if [[ "$config_github" =~ ^[Yy]$ ]]; then
    read -s -p "请输入 GitHub Token: " GITHUB_TOKEN
    echo ""
    read -p "请输入 GitHub 用户名: " GITHUB_USERNAME
    
    # 添加到 shell 配置
    if [ -f "$HOME/.bashrc" ]; then
        sed -i '/GITHUB_TOKEN/d' "$HOME/.bashrc"
        sed -i '/GITHUB_USERNAME/d' "$HOME/.bashrc"
        echo "" >> "$HOME/.bashrc"
        echo "# GitHub" >> "$HOME/.bashrc"
        echo "export GITHUB_TOKEN=\"$GITHUB_TOKEN\"" >> "$HOME/.bashrc"
        echo "export GITHUB_USERNAME=\"$GITHUB_USERNAME\"" >> "$HOME/.bashrc"
    fi
    
    if [ -f "$HOME/.zshrc" ]; then
        sed -i '/GITHUB_TOKEN/d' "$HOME/.zshrc"
        sed -i '/GITHUB_USERNAME/d' "$HOME/.zshrc"
        echo "" >> "$HOME/.zshrc"
        echo "# GitHub" >> "$HOME/.zshrc"
        echo "export GITHUB_TOKEN=\"$GITHUB_TOKEN\"" >> "$HOME/.zshrc"
        echo "export GITHUB_USERNAME=\"$GITHUB_USERNAME\"" >> "$HOME/.zshrc"
    fi
    
    echo -e "${GREEN}✓${NC} GitHub Token 已配置"
    echo "  已添加到 ~/.bashrc 和 ~/.zshrc"
fi

# ═══════════════════════════════════════════════════════════════
# 步骤 6：重启并验证
# ═══════════════════════════════════════════════════════════════
step_title 6 "重启服务并验证"

echo "即将重启 OpenClaw 服务以应用所有配置..."
echo ""

if confirm_continue; then
    echo -e "${BLUE}重启 OpenClaw...${NC}"
    openclaw gateway restart
    
    echo ""
    echo "等待服务启动..."
    sleep 3
    
    echo ""
    echo -e "${BLUE}验证安装...${NC}"
    echo ""
    
    # 检查版本
    echo "OpenClaw 版本:"
    openclaw --version 2>&1 | head -1 || true
    echo ""
    
    # 检查已安装技能
    echo "已安装技能（ClawHub）:"
    clawhub list 2>&1 || echo "  无法获取技能列表"
    echo ""
    
    # 检查子智能体
    echo "子智能体配置:"
    if [ -f "$HOME/.openclaw/agents_config.json" ]; then
        grep -o '"id": "[^"]*"' "$HOME/.openclaw/agents_config.json" | sed 's/"id": "//;s/"$//' | sed 's/^/  - /'
    fi
    echo ""
    
    echo -e "${GREEN}✓${NC} 验证完成"
else
    echo -e "${YELLOW}跳过重启${NC}"
fi

# ═══════════════════════════════════════════════════════════════
# 完成总结
# ═══════════════════════════════════════════════════════════════
echo ""
print_line
echo -e "${GREEN}🎉 XClaw 配置完成！${NC}"
print_line
echo ""

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                         下一步操作                           ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  1. 重新加载 Shell 配置:                                     ║
║     source ~/.bashrc  (或 source ~/.zshrc)                   ║
║                                                              ║
║  2. 检查 OpenClaw 状态:                                      ║
║     openclaw status                                          ║
║                                                              ║
║  3. 测试子智能体:                                            ║
║     发送消息: "启动 coordinator 帮我规划论文写作"            ║
║                                                              ║
║  4. 查看完整文档:                                            ║
║     cat README.md                                            ║
║                                                              ║
║  5. 探索技能列表:                                            ║
║     clawhub list                                             ║
║     ls ~/.openclaw/skills/                                   ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF

echo ""
echo -e "${CYAN}已配置的子智能体：${NC}"
echo "  researcher   - 文献调研员（文献检索、知识提取）"
echo "  idea         - 创意生成器（创新点挖掘）"
echo "  mentor       - 导师审核员（方案评估）"
echo "  architect    - 架构设计师（系统设计）"
echo "  coder        - 实验工程师（代码实现）"
echo "  writer       - 论文撰写员（学术写作）"
echo "  reviewer     - 论文审稿人（质量检查）"
echo "  coordinator  - 科研主管（整体协调）"
echo ""

if [ -n "$MATON_API_KEY" ]; then
    echo -e "${GREEN}✓${NC} Maton API Gateway 已配置，可以发送邮件"
fi
if [ -n "$TAVILY_API_KEY" ]; then
    echo -e "${GREEN}✓${NC} Tavily 搜索已配置"
fi
if [ -n "$GITHUB_TOKEN" ]; then
    echo -e "${GREEN}✓${NC} GitHub 集成已配置"
fi

echo ""
echo -e "${YELLOW}提示：如果子智能体未正常工作，请检查：${NC}"
echo "  1. 是否已将 agents 配置合并到 ~/.openclaw/openclaw.json"
echo "  2. 运行: openclaw gateway restart"
echo "  3. 查看日志: openclaw logs --follow"
echo ""

print_line
echo -e "${CYAN}感谢使用 XClaw 配置脚本！${NC}"
print_line
echo ""
