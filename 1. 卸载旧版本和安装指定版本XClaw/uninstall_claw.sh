#!/bin/bash
# 不使用 set -e，允许命令失败继续执行
set +e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🦞 OpenClaw 彻底卸载脚本（健壮版）${NC}"
echo -e "${BLUE}========================${NC}"
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

# 1. 停止所有进程（使用多种方法确保停止）
echo -e "${BLUE}[1/8]${NC} 停止 OpenClaw 进程..."
# 方法1：使用 killall（比 pkill 更稳定）
killall -q openclaw-gateway 2>/dev/null || true
killall -q openclaw-runtime 2>/dev/null || true
killall -q openclaw 2>/dev/null || true
# 方法2：使用 ps + kill（更兼容）
ps aux | grep -E 'openclaw|openclaw-gateway|openclaw-runtime' | grep -v grep | awk '{print $2}' | xargs -r kill -9 2>/dev/null || true
sleep 2
echo -e "${GREEN}✓ 进程已停止或不存在${NC}"

# 2. 卸载 NPM 全局包
echo -e "${BLUE}[2/8]${NC} 卸载 NPM 全局安装..."
npm uninstall -g openclaw 2>/dev/null || echo -e "${YELLOW}  (NPM 包不存在或已卸载)${NC}"

# 3. 删除系统级二进制文件（多个可能位置）
echo -e "${BLUE}[3/8]${NC} 清理系统级二进制文件..."
sudo rm -f /usr/local/bin/openclaw 2>/dev/null || true
sudo rm -f /usr/local/sbin/openclaw 2>/dev/null || true
sudo rm -f /usr/bin/openclaw 2>/dev/null || true
sudo rm -f /bin/openclaw 2>/dev/null || true
sudo rm -rf /opt/openclaw 2>/dev/null || true
echo -e "${GREEN}✓ 系统级文件已清理${NC}"

# 4. 删除用户级二进制文件
echo -e "${BLUE}[4/8]${NC} 清理用户级二进制文件..."
rm -f "$HOME/.local/bin/openclaw" 2>/dev/null || true
rm -f "$HOME/bin/openclaw" 2>/dev/null || true
rm -f "$HOME/.openclaw/bin/openclaw" 2>/dev/null || true
echo -e "${GREEN}✓ 用户级文件已清理${NC}"

# 5. 删除 systemd 服务（如果存在）
echo -e "${BLUE}[5/8]${NC} 清理系统服务..."
if [ -f "/etc/systemd/system/openclaw.service" ]; then
    sudo systemctl stop openclaw 2>/dev/null || true
    sudo systemctl disable openclaw 2>/dev/null || true
    sudo rm -f /etc/systemd/system/openclaw.service
    sudo rm -f /usr/lib/systemd/system/openclaw.service
    sudo rm -f "$HOME/.config/systemd/user/openclaw.service"
    sudo systemctl daemon-reload 2>/dev/null || true
    echo -e "${GREEN}✓ 系统服务已删除${NC}"
else
    echo -e "${YELLOW}  (未找到系统服务)${NC}"
fi

# 6. 删除配置目录（核心步骤，带确认）
echo -e "${BLUE}[6/8]${NC} 处理配置目录 ~/.openclaw..."
if [ -d "$HOME/.openclaw" ]; then
    echo -e "${YELLOW}  发现配置目录，包含:${NC}"
    ls -la "$HOME/.openclaw" | head -10
    echo ""
    read -p "  确认彻底删除 ~/.openclaw (含插件/配置)? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/.openclaw"
        echo -e "${GREEN}✓ 配置目录已删除${NC}"
    else
        echo -e "${YELLOW}  (保留配置目录)${NC}"
    fi
else
    echo -e "${YELLOW}  (配置目录不存在)${NC}"
fi

# 7. 清理 shell 配置文件
echo -e "${BLUE}[7/8]${NC} 清理 Shell 配置..."
for rcfile in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.bash_profile"; do
    if [ -f "$rcfile" ]; then
        # 创建备份
        cp "$rcfile" "$rcfile.bak.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
        # 删除 openclaw 相关行（包括补全、别名、环境变量）
        sed -i '/openclaw/d' "$rcfile" 2>/dev/null || true
        sed -i '/OPENCLAW/d' "$rcfile" 2>/dev/null || true
    fi
done
hash -r 2>/dev/null || true
echo -e "${GREEN}✓ Shell 配置已清理${NC}"

# 8. 清理缓存和临时文件
echo -e "${BLUE}[8/8]${NC} 清理缓存..."
rm -rf "$HOME/.npm/_npx/*/node_modules/openclaw" 2>/dev/null || true
rm -rf "$HOME/.cache/openclaw" 2>/dev/null || true
rm -rf /tmp/openclaw* 2>/dev/null || true
rm -rf "$HOME/.config/openclaw" 2>/dev/null || true
echo -e "${GREEN}✓ 缓存已清理${NC}"

echo ""
echo -e "${BLUE}========================${NC}"
echo -e "${GREEN}🎉 OpenClaw 卸载流程已完成！${NC}"
echo ""

# 验证结果
echo -e "${BLUE}验证结果:${NC}"
OPENCLAW_PATH=$(which openclaw 2>/dev/null || echo "")
if [ -z "$OPENCLAW_PATH" ]; then
    echo -e "${GREEN}✓ OpenClaw 已成功从系统中移除${NC}"
else
    echo -e "${RED}⚠ 警告: 仍发现 openclaw 存在于: $OPENCLAW_PATH${NC}"
    echo -e "${YELLOW}  可能需要手动删除: sudo rm -f $OPENCLAW_PATH${NC}"
fi

# 检查残留配置
if [ -d "$HOME/.openclaw" ]; then
    echo -e "${YELLOW}⚠ 配置目录 ~/.openclaw 仍存在${NC}"
else
    echo -e "${GREEN}✓ 配置目录已清除${NC}"
fi

echo ""
echo -e "${BLUE}建议操作:${NC}"
echo "1. 重启终端或执行: ${YELLOW}source ~/.bashrc${NC}"
echo "2. 如需重装: ${YELLOW}npm install -g openclaw@2026.3.17${NC}"
echo "3. 检查 Docker 容器（如有）: ${YELLOW}docker ps | grep openclaw${NC}"