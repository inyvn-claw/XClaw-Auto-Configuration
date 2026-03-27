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

## 🚀 快速开始（复刻指南）

### 步骤 1：安装 OpenClaw

```bash
# 安装指定版本（推荐 2026.3.13）
npm install -g openclaw@2026.3.13

# 初始化配置
openclaw onboard --install-daemon
```

> 详细步骤见 [1. 卸载旧版本和安装指定版本XClaw](./1.%20卸载旧版本和安装指定版本XClaw/)

---

### 步骤 2：安装飞书插件（如使用飞书）

```bash
npx -y @larksuite/openclaw-lark@2026.3.17 install
```

---

### 步骤 3：配置子智能体

**方式 A：复制配置文件（推荐）**

```bash
# 1. 克隆本仓库
git clone https://github.com/your-username/XClaw-Config.git
cd XClaw-Config

# 2. 复制子智能体配置文件
cp -r "4.子智能体/workspace-"* ~/.openclaw/

# 3. 更新 openclaw.json
cp "4.子智能体/agents_config.json" ~/.openclaw/openclaw.json
```

**方式 B：手动配置**

编辑 `~/.openclaw/openclaw.json`，添加以下 agents 配置：

```json
{
  "agents": {
    "list": [
      {
        "id": "researcher",
        "name": "文献调研",
        "workspace": "~/.openclaw/workspace-researcher",
        "model": "kimi-coding/k2p5"
      },
      {
        "id": "idea",
        "name": "创意生成",
        "workspace": "~/.openclaw/workspace-idea",
        "model": "kimi-coding/k2p5"
      },
      {
        "id": "mentor",
        "name": "导师审核",
        "workspace": "~/.openclaw/workspace-mentor",
        "model": "kimi-coding/k2p5"
      },
      {
        "id": "architect",
        "name": "架构设计",
        "workspace": "~/.openclaw/workspace-architect",
        "model": "kimi-coding/k2p5"
      },
      {
        "id": "coder",
        "name": "实验 coder",
        "workspace": "~/.openclaw/workspace-coder",
        "model": "kimi-coding/k2p5"
      },
      {
        "id": "writer",
        "name": "论文撰写",
        "workspace": "~/.openclaw/workspace-writer",
        "model": "kimi-coding/k2p5"
      },
      {
        "id": "reviewer",
        "name": "论文审稿",
        "workspace": "~/.openclaw/workspace-reviewer",
        "model": "kimi-coding/k2p5"
      },
      {
        "id": "coordinator",
        "name": "科研主管",
        "workspace": "~/.openclaw/workspace-coordinator",
        "model": "kimi-coding/k2p5"
      }
    ]
  }
}
```

---

### 步骤 4：安装技能

**一键安装脚本：**

```bash
# 安装 LabClaw（240个生物医学技能）
cd ~/.openclaw/skills
git clone https://github.com/wu-yc/LabClaw.git
cp -r LabClaw/skills/* .

# 安装 ClawHub 技能（科研核心技能）
clawhub install arxiv-watcher
clawhub install literature-review
clawhub install perplexity
clawhub install senior-architect
clawhub install test-runner
clawhub install docker-essentials
clawhub install wandb-monitor
clawhub install ai-pdf-builder
clawhub install typetex
clawhub install chart-image
clawhub install git-essentials
clawhub install god-mode
clawhub install api-gateway
```

> 完整技能列表见 [3.skills/README.md](./3.skills/)

---

### 步骤 5：配置 API 密钥

#### 5.1 Maton API Gateway（可选，用于邮件/办公集成）

```bash
# 设置环境变量
export MATON_API_KEY="your-maton-api-key"

# 或添加到配置文件
echo 'export MATON_API_KEY="your-maton-api-key"' >> ~/.bashrc
```

获取 API Key：https://maton.ai/settings

#### 5.2 GitHub（可选）

```bash
export GITHUB_TOKEN="ghp_your_token"
export GITHUB_USERNAME="your_username"
```

---

### 步骤 6：重启服务

```bash
openclaw gateway restart
```

---

## 📁 项目结构

```
XClaw自动配置指南/
├── 1. 卸载旧版本和安装指定版本XClaw/  # OpenClaw 安装指南
│   ├── README.md
│   └── uninstall_claw.sh
├── 2.浏览器控制和联网搜索/               # 浏览器配置
│   └── README.md
├── 3.skills/                            # 技能管理
│   └── README.md
├── 4.子智能体/                          # 8个科研子智能体
│   ├── README.md                        # 子智能体说明
│   ├── 子智能体技能配置指南.md          # 技能分配详情
│   ├── skills-科研.md                   # 科研技能清单
│   ├── agents_config.json               # 配置文件
│   ├── workspace-researcher/            # 文献调研员工作区
│   ├── workspace-idea/                  # 创意生成器工作区
│   ├── workspace-mentor/                # 导师审核员工作区
│   ├── workspace-architect/             # 架构设计师工作区
│   ├── workspace-coder/                 # 实验工程师工作区
│   ├── workspace-writer/                # 论文撰写员工作区
│   ├── workspace-reviewer/              # 论文审稿人工作区
│   └── workspace-coordinator/           # 科研主管工作区
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

## ⚙️ 配置说明

### 核心配置文件

| 文件 | 用途 | 复刻方式 |
|------|------|---------|
| `~/.openclaw/openclaw.json` | 主配置（agents、models、channels） | 复制 `agents_config.json` |
| `~/.openclaw/workspace-*/SKILL.md` | 各子智能体技能配置 | 复制 `workspace-*` 目录 |
| `~/.openclaw/workspace-*/SOUL.md` | 子智能体人格定义 | 已包含在工作区 |
| `~/.openclaw/skills/` | 技能目录 | 运行安装脚本 |

### 需要手动配置的部分

| 配置项 | 说明 | 获取方式 |
|--------|------|---------|
| `MATON_API_KEY` | API 网关密钥 | https://maton.ai/settings |
| `GITHUB_TOKEN` | GitHub 访问令牌 | https://github.com/settings/tokens |
| 飞书 App ID/Secret | 飞书集成 | 飞书开放平台 |

---

## ✅ 复刻检查清单

- [ ] 安装 OpenClaw 2026.3.13
- [ ] 安装飞书插件（如需要）
- [ ] 复制子智能体工作区配置
- [ ] 安装 LabClaw 技能
- [ ] 安装 ClawHub 核心技能
- [ ] 配置 MATON_API_KEY（如需要邮件功能）
- [ ] 配置 GITHUB_TOKEN（如需要 GitHub 集成）
- [ ] 重启 OpenClaw 服务
- [ ] 测试子智能体启动

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

- [OpenClaw 官方文档](https://docs.openclaw.ai/)
- [ClawHub 技能市场](https://clawhub.com/)
- [LabClaw 技能库](https://github.com/wu-yc/LabClaw)
- [Maton API Gateway](https://maton.ai/)

---

## 📝 贡献指南

欢迎提交 Issue 和 PR！请确保：
- 配置文件不包含敏感信息（API Key、Token）
- 文档清晰易懂
- 脚本经过测试

---

## 📄 许可证

MIT License

---

*最后更新：2026-03-27*
