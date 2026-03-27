# XClaw 自动配置指南

> 🦞 一键复刻完整的 OpenClaw 科研助手配置

---

## 📋 项目概述

本项目提供了一套完整的 OpenClaw 配置方案，专为科研工作流程设计，包含：

- ✅ 8 个科研专用子智能体（文献调研 → 论文审稿全流程）
- ✅ 265+ 个技能（LabClaw 240个 + ClawHub 25+个）
- ✅ 完整的论文工作流自动化
- ✅ API 网关集成（邮件、办公、开发工具）

**适用场景：**
- 学术研究全流程管理
- 论文撰写与审稿
- 实验设计与代码实现
- 科研团队协作

---

## 🚀 快速开始（推荐方式）

### 方式一：交互式一键配置（推荐 ⭐）

```bash
# 1. 克隆仓库
git clone https://github.com/inyvn-claw/XClaw-Auto-Configuration.git
cd XClaw-Auto-Configuration

# 2. 运行交互式配置脚本
./setup.sh
```

**`setup.sh` 会自动完成以下配置：**

| 步骤 | 内容 | 说明 |
|------|------|------|
| 1 | 安装 OpenClaw | 自动检测并安装指定版本 |
| 2 | 安装飞书插件 | 可选，如使用飞书渠道 |
| 3 | 配置 8 个子智能体 | 自动复制工作区和配置文件 |
| 4 | 安装 265+ 技能 | LabClaw + ClawHub 核心技能 |
| 5 | 配置 API Key | 交互式输入 Maton/Tavily/GitHub |
| 6 | 重启并验证 | 自动重启服务并检查状态 |

运行脚本后，按提示操作即可！

---

### 方式二：手动配置

如需手动配置，请参考以下步骤：

#### 步骤 1：安装 OpenClaw

```bash
# 安装指定版本（推荐 2026.3.13）
npm install -g openclaw@2026.3.13

# 初始化配置
openclaw onboard --install-daemon
```

> 详细步骤见 [1. 卸载旧版本和安装指定版本XClaw](./1.%20卸载旧版本和安装指定版本XClaw/)

#### 步骤 2：安装飞书插件（可选）

```bash
npx -y @larksuite/openclaw-lark@2026.3.17 install
```

#### 步骤 3：配置子智能体

```bash
# 复制子智能体工作区
cp -r "4.子智能体/workspace-"* ~/.openclaw/

# 生成配置文件（从模板）
sed "s|{{HOME}}|$HOME|g" "4.子智能体/agents_config.template.json" > ~/.openclaw/agents_config.json
```

#### 步骤 4：安装技能

```bash
# 安装 LabClaw（240个生物医学技能）
cd ~/.openclaw/skills
git clone https://github.com/wu-yc/LabClaw.git
cp -r LabClaw/skills/* .

# 安装 ClawHub 核心技能
clawhub install arxiv-watcher literature-review perplexity
clawhub install senior-architect backend-patterns
clawhub install test-runner docker-essentials wandb-monitor debug-pro
clawhub install ai-pdf-builder typetex chart-image nano-pdf
clawhub install git-essentials get-tldr claude-optimised god-mode
clawhub install api-gateway
```

#### 步骤 5：配置 API 密钥

```bash
# Maton API Gateway（可选，用于邮件/办公集成）
export MATON_API_KEY="your-maton-api-key"

# GitHub（可选）
export GITHUB_TOKEN="ghp_your_token"
export GITHUB_USERNAME="your_username"
```

#### 步骤 6：重启服务

```bash
openclaw gateway restart
```

---

## 📁 项目结构

```
XClaw-Auto-Configuration/
├── README.md                      # 本文件
├── setup.sh                       # ⭐ 交互式一键配置脚本
├── install.sh                     # 非交互式安装脚本
├── validate.sh                    # 配置验证脚本
├── LICENSE                        # MIT 许可证
├── .gitignore                     # Git 忽略规则
│
├── 1. 卸载旧版本和安装指定版本XClaw/  # OpenClaw 安装指南
│   ├── README.md
│   └── uninstall_claw.sh
│
├── 2.浏览器控制和联网搜索/               # 浏览器配置
│   └── README.md
│
├── 3.skills/                            # 技能管理
│   └── README.md
│
├── 4.子智能体/                          # 8个科研子智能体
│   ├── README.md                        # 子智能体说明
│   ├── 子智能体技能配置指南.md          # 技能分配详情
│   ├── skills-科研.md                   # 科研技能清单
│   ├── agents_config.template.json      # 配置模板
│   ├── workspace-researcher/            # 文献调研员工作区
│   ├── workspace-idea/                  # 创意生成器工作区
│   ├── workspace-mentor/                # 导师审核员工作区
│   ├── workspace-architect/             # 架构设计师工作区
│   ├── workspace-coder/                 # 实验工程师工作区
│   ├── workspace-writer/                # 论文撰写员工作区
│   ├── workspace-reviewer/              # 论文审稿人工作区
│   └── workspace-coordinator/           # 科研主管工作区
│
└── 5.科研协作平台/                      # （可选）部署指南
    └── README.md
```

---

## 🎯 使用方法

### 启动科研工作流

```bash
# 使用 coordinator 启动完整工作流
sessions_spawn({
  "task": "我想写一篇关于深度学习的论文，请协调各子智能体完成",
  "agentId": "coordinator",
  "mode": "session"
})
```

### 单独使用子智能体

```bash
# 文献调研
sessions_spawn({
  "task": "调研 Transformer 在计算机视觉中的最新进展",
  "agentId": "researcher",
  "mode": "session"
})

# 论文撰写
sessions_spawn({
  "task": "根据实验结果撰写方法章节",
  "agentId": "writer",
  "mode": "session"
})
```

---

## 🔧 故障排查

### 问题 1：子智能体无法启动

```bash
# 检查配置
openclaw status

# 查看日志
openclaw logs --follow
```

### 问题 2：技能未找到

```bash
# 检查技能安装
clawhub list
ls ~/.openclaw/workspace/skills/
```

### 问题 3：API 调用失败

```bash
# 检查环境变量
echo $MATON_API_KEY
echo $GITHUB_TOKEN
```

---

## 📚 相关文档

| 文档 | 说明 |
|------|------|
| [1. 卸载旧版本和安装指定版本XClaw](./1.%20卸载旧版本和安装指定版本XClaw/) | OpenClaw 安装指南 |
| [2.浏览器控制和联网搜索](./2.浏览器控制和联网搜索/) | 浏览器配置说明 |
| [3.skills/](./3.skills/) | 技能管理指南 |
| [4.子智能体/](./4.子智能体/) | 子智能体详细配置 |
| [4.子智能体/子智能体技能配置指南.md](./4.子智能体/子智能体技能配置指南.md) | 技能分配详情 |
| [5.科研协作平台/](./5.科研协作平台/) | 部署指南（可选） |

**外部资源：**
- [OpenClaw 官方文档](https://docs.openclaw.ai/)
- [ClawHub 技能市场](https://clawhub.com/)
- [LabClaw 技能库](https://github.com/wu-yc/LabClaw)
- [Maton API Gateway](https://maton.ai/)

---

## 🛠️ 可用脚本

| 脚本 | 用途 |
|------|------|
| `setup.sh` | ⭐ **交互式一键配置**（推荐） |
| `install.sh` | 非交互式批量安装 |
| `validate.sh` | 配置验证检查 |
| `uninstall_claw.sh` | 卸载 OpenClaw |

---

## 📝 贡献指南

欢迎提交 Issue 和 PR！请确保：
- 配置文件不包含敏感信息（API Key、Token）
- 文档清晰易懂
- 脚本经过测试

---

## 📄 许可证

[MIT License](./LICENSE)

---

## ⭐ Star History

如果觉得本项目有用，请给个 Star ⭐ 支持！

---

*最后更新：2026-03-27*
