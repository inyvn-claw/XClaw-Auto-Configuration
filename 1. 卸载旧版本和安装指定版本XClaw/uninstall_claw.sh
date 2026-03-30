#!/bin/bash
# OpenClaw 彻底卸载脚本 - 参照官方文档优化
# 官方文档: https://docs.openclaw.ai/zh-CN/install/uninstall

# 不使用 set -e，允许命令失败继续执行
set +e

# 检测操作系统
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
fi

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🦞 OpenClaw 彻底卸载脚本（官方文档版）${NC}"
echo -e "${BLUE}========================${NC}"
echo -e "${CYAN}检测系统: $OS${NC}"
echo ""

# 函数：执行命令并显示状态
run_step() {
    local msg="$1"
    local cmd="$2"
    echo -ne "${YELLOW}[执行]${NC} $msg ... "
    eval "$cmd" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC} (忽略)"
        return 1
    fi
}

# ==================== 步骤 1: 停止 Gateway Daemon ====================
echo -e "${BLUE}[1/10]${NC} 停止 OpenClaw Gateway Daemon..."

# 先尝试使用 openclaw 命令优雅停止
if command -v openclaw &> /dev/null; then
    openclaw gateway stop 2>/dev/null || true
    sleep 1
fi

# macOS: 卸载 LaunchAgent
if [ "$OS" = "macos" ]; then
    echo -e "${CYAN}  检测到 macOS，清理 LaunchAgent...${NC}"
    # 停止并卸载用户级 LaunchAgent
    launchctl stop ai.openclaw.gateway 2>/dev/null || true
    launchctl unload "$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist" 2>/dev/null || true
    rm -f "$HOME/Library/LaunchAgents/ai.openclaw.gateway.plist"
    
    # 停止并卸载 GUI 级别 LaunchAgent
    launchctl stop gui/501/ai.openclaw.gateway 2>/dev/null || true
    launchctl unload gui/501/ai.openclaw.gateway 2>/dev/null || true
    
    # 清理所有可能的 LaunchAgent 位置
    rm -f "$HOME/Library/LaunchAgents/ai.openclaw.*"
    rm -f "/Library/LaunchAgents/ai.openclaw.*"
    rm -f "/Library/LaunchDaemons/ai.openclaw.*"
    
    # 使用 launchctl list 检查并移除
    launchctl list | grep openclaw | awk '{print $3}' | while read service; do
        echo -e "${YELLOW}  移除服务: $service${NC}"
        launchctl remove "$service" 2>/dev/null || true
    done
fi

# Linux: 停止 systemd 服务
if [ "$OS" = "linux" ]; then
    echo -e "${CYAN}  检测到 Linux，清理 systemd 服务...${NC}"
    sudo systemctl stop openclaw 2>/dev/null || true
    sudo systemctl stop openclaw-gateway 2>/dev/null || true
    sudo systemctl disable openclaw 2>/dev/null || true
    sudo systemctl disable openclaw-gateway 2>/dev/null || true
fi

# 强制终止所有残留进程
killall -q openclaw-gateway 2>/dev/null || true
killall -q openclaw-runtime 2>/dev/null || true
killall -q openclaw 2>/dev/null || true
ps aux | grep -E 'openclaw|openclaw-gateway|openclaw-runtime' | grep -v grep | awk '{print $2}' | xargs -r kill -9 2>/dev/null || true

sleep 2
echo -e "${GREEN}✓ Gateway Daemon 已停止${NC}"

# ==================== 步骤 2: 卸载 NPM 全局包 ====================
echo -e "${BLUE}[2/10]${NC} 卸载 NPM 全局 openclaw 包..."

# 卸载全局包
npm uninstall -g openclaw 2>/dev/null || true
npm uninstall -g @openclaw/cli 2>/dev/null || true

# 清理 npm 全局 node_modules 中的残留
if [ -d "$(npm root -g)/openclaw" ]; then
    rm -rf "$(npm root -g)/openclaw"
fi

echo -e "${GREEN}✓ NPM 全局包已卸载${NC}"

# ==================== 步骤 3: 删除 CLI 二进制文件 ====================
echo -e "${BLUE}[3/10]${NC} 删除 CLI 二进制文件..."

# 获取 npm 全局 bin 目录
NPM_BIN="$(npm bin -g 2>/dev/null || echo '/usr/local/bin')"

# 删除可能的二进制文件位置
rm -f "$NPM_BIN/openclaw" 2>/dev/null || true
rm -f "/usr/local/bin/openclaw" 2>/dev/null || true
rm -f "/usr/local/sbin/openclaw" 2>/dev/null || true
rm -f "/usr/bin/openclaw" 2>/dev/null || true
rm -f "/bin/openclaw" 2>/dev/null || true
rm -f "$HOME/.local/bin/openclaw" 2>/dev/null || true
rm -f "$HOME/bin/openclaw" 2>/dev/null || true
rm -f "$HOME/.openclaw/bin/openclaw" 2>/dev/null || true
rm -rf "/opt/openclaw" 2>/dev/null || true

# macOS 特定位置
if [ "$OS" = "macos" ]; then
    rm -f "/opt/homebrew/bin/openclaw" 2>/dev/null || true
    rm -f "/usr/local/opt/openclaw/bin/openclaw" 2>/dev/null || true
fi

echo -e "${GREEN}✓ CLI 二进制文件已删除${NC}"

# ==================== 步骤 4: 删除 npx 缓存 ====================
echo -e "${BLUE}[4/10]${NC} 删除 npx 缓存..."

rm -rf "$HOME/.npm/_npx" 2>/dev/null || true
rm -f "$HOME/.npm/bin/openclaw" 2>/dev/null || true

echo -e "${GREEN}✓ npx 缓存已删除${NC}"

# ==================== 步骤 5: 删除系统服务配置 ====================
echo -e "${BLUE}[5/10]${NC} 删除系统服务配置..."

if [ "$OS" = "macos" ]; then
    # macOS LaunchAgent/Daemon 已在步骤 1 处理
    echo -e "${CYAN}  macOS LaunchAgent 已在步骤 1 清理${NC}"
elif [ "$OS" = "linux" ]; then
    # Linux systemd 服务文件
    echo -e "${CYAN}  清理 systemd 服务文件...${NC}"
    
    # 系统级服务
    sudo rm -f "/etc/systemd/system/openclaw.service"
    sudo rm -f "/etc/systemd/system/openclaw-gateway.service"
    sudo rm -f "/usr/lib/systemd/system/openclaw.service"
    sudo rm -f "/usr/lib/systemd/system/openclaw-gateway.service"
    
    # 用户级服务
    rm -f "$HOME/.config/systemd/user/openclaw.service"
    rm -f "$HOME/.config/systemd/user/openclaw-gateway.service"
    
    # 重新加载 systemd
    sudo systemctl daemon-reload 2>/dev/null || true
    systemctl --user daemon-reload 2>/dev/null || true
    
    echo -e "${GREEN}✓ systemd 服务已删除${NC}"
else
    echo -e "${YELLOW}  未知系统类型，跳过服务清理${NC}"
fi

echo -e "${GREEN}✓ 系统服务配置已删除${NC}"

# ==================== 步骤 6: 删除配置文件 ====================
echo -e "${BLUE}[6/10]${NC} 处理配置文件 ~/.openclaw..."

if [ -d "$HOME/.openclaw" ]; then
    echo -e "${YELLOW}  发现配置目录 ~/.openclaw${NC}"
    echo -e "${CYAN}  包含内容:${NC}"
    du -sh "$HOME/.openclaw" 2>/dev/null || ls -la "$HOME/.openclaw" | head -10
    echo ""
    read -p "  确认彻底删除 ~/.openclaw (含所有插件/配置/工作区)? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/.openclaw"
        echo -e "${GREEN}✓ 配置目录已删除${NC}"
    else
        echo -e "${YELLOW}  (保留配置目录，如需完全卸载请手动删除)${NC}"
    fi
else
    echo -e "${YELLOW}  (配置目录不存在)${NC}"
fi

# ==================== 步骤 7: 清理 Shell 配置 ====================
echo -e "${BLUE}[7/10]${NC} 清理 Shell 配置文件..."

SHELL_FILES=(
    "$HOME/.bashrc"
    "$HOME/.zshrc"
    "$HOME/.profile"
    "$HOME/.bash_profile"
    "$HOME/.zprofile"
)

for rcfile in "${SHELL_FILES[@]}"; do
    if [ -f "$rcfile" ]; then
        # 检查是否包含 openclaw 相关内容
        if grep -q "openclaw\|OPENCLAW" "$rcfile" 2>/dev/null; then
            # 创建备份
            cp "$rcfile" "$rcfile.bak.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
            # 删除 openclaw 相关行
            sed -i.bak '/openclaw/d' "$rcfile" 2>/dev/null || true
            sed -i.bak '/OPENCLAW/d' "$rcfile" 2>/dev/null || true
            rm -f "$rcfile.bak" 2>/dev/null || true
            echo -e "${CYAN}  已清理: $rcfile${NC}"
        fi
    fi
done

hash -r 2>/dev/null || true
echo -e "${GREEN}✓ Shell 配置已清理${NC}"

# ==================== 步骤 8: 清理缓存和临时文件 ====================
echo -e "${BLUE}[8/10]${NC} 清理缓存和临时文件..."

# npm 缓存
rm -rf "$HOME/.npm/_npx" 2>/dev/null || true
rm -rf "$HOME/.npm/_cacache" 2>/dev/null || true
rm -f "$HOME/.npm/bin/openclaw" 2>/dev/null || true

# OpenClaw 缓存
rm -rf "$HOME/.cache/openclaw" 2>/dev/null || true
rm -rf "$HOME/.config/openclaw" 2>/dev/null || true

# 临时文件
rm -rf /tmp/openclaw* 2>/dev/null || true
rm -rf /var/tmp/openclaw* 2>/dev/null || true
rm -rf "$HOME/.openclaw.tmp" 2>/dev/null || true

# macOS 特定缓存
if [ "$OS" = "macos" ]; then
    rm -rf "$HOME/Library/Caches/openclaw" 2>/dev/null || true
    rm -rf "$HOME/Library/Caches/ai.openclaw" 2>/dev/null || true
    rm -rf "$HOME/Library/Application Support/openclaw" 2>/dev/null || true
fi

# Linux 特定缓存
if [ "$OS" = "linux" ]; then
    rm -rf "$HOME/.local/share/openclaw" 2>/dev/null || true
    rm -rf "$HOME/.local/cache/openclaw" 2>/dev/null || true
    rm -rf "/var/cache/openclaw" 2>/dev/null || true
fi

echo -e "${GREEN}✓ 缓存和临时文件已清理${NC}"

# ==================== 步骤 9: 清理日志文件 ====================
echo -e "${BLUE}[9/10]${NC} 清理日志文件..."

rm -rf "$HOME/.openclaw/logs" 2>/dev/null || true
rm -f "$HOME/Library/Logs/openclaw" 2>/dev/null || true

# Linux 系统日志
if [ "$OS" = "linux" ]; then
    rm -f "/var/log/openclaw" 2>/dev/null || true
    rm -f "/var/log/openclaw-gateway" 2>/dev/null || true
    rm -rf "$HOME/.local/state/openclaw" 2>/dev/null || true
    # 清理 systemd journal 中 openclaw 相关日志
    journalctl --user --unit=openclaw --rotate 2>/dev/null || true
    journalctl --user --unit=openclaw --vacuum-time=1s 2>/dev/null || true
fi

echo -e "${GREEN}✓ 日志文件已清理${NC}"

# ==================== 步骤 10: 清理环境变量 ====================
echo -e "${BLUE}[10/10]${NC} 清理环境变量..."

unset OPENCLAW_HOME 2>/dev/null || true
unset OPENCLAW_CONFIG 2>/dev/null || true
unset OPENCLAW_TOKEN 2>/dev/null || true

echo -e "${GREEN}✓ 环境变量已清理${NC}"

# ==================== 验证结果 ====================
echo ""
echo -e "${BLUE}========================${NC}"
echo -e "${GREEN}🎉 OpenClaw 卸载流程已完成！${NC}"
echo -e "${BLUE}========================${NC}"
echo ""

echo -e "${BLUE}验证结果:${NC}"

# 检查 openclaw 命令
OPENCLAW_PATH=$(which openclaw 2>/dev/null || echo "")
if [ -z "$OPENCLAW_PATH" ]; then
    echo -e "${GREEN}✓ OpenClaw CLI 已完全移除${NC}"
else
    echo -e "${RED}⚠ 警告: 仍发现 openclaw 存在于: $OPENCLAW_PATH${NC}"
    echo -e "${YELLOW}  手动删除: rm -f $OPENCLAW_PATH${NC}"
fi

# 检查配置目录
if [ -d "$HOME/.openclaw" ]; then
    echo -e "${YELLOW}⚠ 配置目录 ~/.openclaw 仍存在${NC}"
    echo -e "${YELLOW}  如需删除: rm -rf ~/.openclaw${NC}"
else
    echo -e "${GREEN}✓ 配置目录已清除${NC}"
fi

# 检查 gateway 进程
if pgrep -f "openclaw-gateway" >/dev/null 2>&1; then
    echo -e "${RED}⚠ 警告: openclaw-gateway 进程仍在运行${NC}"
    echo -e "${YELLOW}  手动终止: killall -9 openclaw-gateway${NC}"
else
    echo -e "${GREEN}✓ Gateway 进程已停止${NC}"
fi

# macOS: 检查 LaunchAgent
if [ "$OS" = "macos" ]; then
    if launchctl list 2>/dev/null | grep -q "openclaw"; then
        echo -e "${YELLOW}⚠ 仍发现 LaunchAgent 服务${NC}"
        launchctl list | grep "openclaw"
    else
        echo -e "${GREEN}✓ LaunchAgent 已清除${NC}"
    fi
fi

# Linux: 检查 systemd 服务
if [ "$OS" = "linux" ]; then
    if systemctl list-unit-files 2>/dev/null | grep -q "openclaw"; then
        echo -e "${YELLOW}⚠ 仍发现 systemd 服务${NC}"
        systemctl list-unit-files | grep "openclaw"
    else
        echo -e "${GREEN}✓ systemd 服务已清除${NC}"
    fi
    
    # 检查用户级 systemd
    if systemctl --user list-unit-files 2>/dev/null | grep -q "openclaw"; then
        echo -e "${YELLOW}⚠ 仍发现用户级 systemd 服务${NC}"
        systemctl --user list-unit-files | grep "openclaw"
    fi
fi

echo ""
echo -e "${BLUE}后续操作建议:${NC}"
echo -e "1. 重启终端或执行: ${YELLOW}source ~/.bashrc${NC} 或 ${YELLOW}source ~/.zshrc${NC}"
echo -e "2. 验证卸载: ${YELLOW}openclaw --version${NC} (应显示命令未找到)"
echo -e "3. 如需重装: ${YELLOW}npm install -g openclaw@2026.3.13${NC}"
echo ""
echo -e "${CYAN}如有问题，参考: https://docs.openclaw.ai/zh-CN/install/uninstall${NC}"