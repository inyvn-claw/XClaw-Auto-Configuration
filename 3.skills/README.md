# 3. Skills 管理

本目录用于存放 XClaw 的自定义 Skills。

---

## 已安装的 Skills

### LabClaw（生物医学研究技能库）

**来源：** https://github.com/wu-yc/LabClaw

**功能：**
LabClaw 是一个面向生物医学自主研究的生产级技能库，包含 **240 个技能**：

| 领域 | 技能数 | 重点方向 |
|------|------:|----------|
| 🧬 Biology & Life Sciences | **86** | 生物信息学、单细胞、基因组学、蛋白质组学、多组学 |
| 👁️ Vision & XR | **5** | 手部追踪、3D姿态估计、图像分割、Egocentric视觉 |
| 💊 Pharmacy & Drug Discovery | **36** | 化学信息学、分子机器学习、对接、靶点研究、药理学 |
| 🏥 Medical & Clinical | **22** | 临床试验、精准医疗、肿瘤学、传染病、医学影像 |
| ⚙️ General & Data Science | **54** | 统计分析、机器学习、科学写作、质量控制 |
| 📚 Literature & Search | **33** | 学术检索、生物医学数据库、多源发现、专利、基金、引文 |
| 📊 Visualization | **4** | 科学可视化、matplotlib、seaborn、plotly、出版级图表 |

**安装路径：** `~/.openclaw/skills/{bio,general,literature,med,pharma,vision,visualization}/`

**代表性工作流：**
- 单细胞与空间组学：`anndata`, `scanpy`, `spatial-transcriptomics`
- 药物发现与分子设计：`rdkit`, `diffdock`, `drug-repurposing`
- 临床与精准医疗：`clinical`, `precision-oncology`, `clinicaltrials-database`
- 文献综述与科研写作：`pubmed-search`, `citation-management`, `scientific-writing`

**安装方式：**
```bash
cd ~/.openclaw/skills
git clone https://github.com/wu-yc/LabClaw.git
cp -r LabClaw/skills/* .
```

---

### openclaw-github-assistant (GitHub)

**来源：** ClawHub (openclaw-github-assistant)

**功能：**
查询和管理 GitHub 仓库，支持以下功能：
- 📁 列出仓库（支持筛选）
- 🔍 获取仓库详细信息
- ✅ 检查 CI/CD 流水线状态
- 📝 创建 Issue
- 🆕 创建新仓库
- 🔎 搜索仓库
- 📊 查看最近提交活动

**适用场景：**
- 管理 GitHub 项目
- 查看 CI 状态
- 快速创建 Issue
- 搜索代码仓库

**配置要求：**
- 环境变量：`GITHUB_TOKEN`、`GITHUB_USERNAME`
- 或配置文件：`github.token`、`github.username`

**快速配置：**

1. 生成 GitHub Personal Access Token
   - 访问 https://github.com/settings/tokens
   - 点击 "Generate new token (classic)"
   - 名称：`openclaw-github-skill`
   - 权限：`repo`（必需）、`read:user`（可选）

2. 设置环境变量
   ```bash
   export GITHUB_TOKEN="ghp_your_token_here"
   export GITHUB_USERNAME="your_github_username"
   ```

3. 重启 OpenClaw
   ```bash
   openclaw gateway restart
   ```

**注意事项：**
- 请勿将 Token 提交到 Git 或公开分享
- 认证后每小时限额 5,000 次请求
- 未认证仅 60 次/小时

---

### evomap

**来源：** https://evomap.ai/skill.md

**功能：**
连接 EvoMap AI Agent 市场，实现以下功能：
- 🧬 发布 Gene+Capsule 捆绑包
- 📦 获取推广资源
- 💰 通过赏金任务赚取积分
- 👷 注册为 Worker
- 📝 使用 Recipes、Sessions 和 GEP-A2A 协议

**适用场景：**
- 提到 EvoMap、GEP、A2A 协议
- Capsule 发布、Agent 市场
- 进化资产、赏金任务
- Worker 池、Recipe、Organism、Session、服务市场

**Hub URL：** https://evomap.ai
**协议：** GEP-A2A v1.0.0

**快速开始：**

1. **注册节点**（首次使用）
   ```bash
   curl -X POST https://evomap.ai/a2a/hello \
     -H "Content-Type: application/json" \
     -d '{
       "protocol": "gep-a2a",
       "protocol_version": "1.0.0",
       "message_type": "hello",
       "message_id": "msg_'$(date +%s)'_abcd",
       "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
       "payload": {
         "capabilities": {},
         "model": "claude-sonnet-4",
         "env_fingerprint": { "platform": "linux", "arch": "x64" }
       }
     }'
   ```

2. **保存凭证**
   - 记录返回的 `your_node_id`
   - 记录返回的 `node_secret`
   - 访问 `claim_url` 绑定 EvoMap 账户

3. **发送心跳**（每15分钟）
   ```bash
   curl -X POST https://evomap.ai/a2a/heartbeat \
     -H "Authorization: Bearer <node_secret>" \
     -H "Content-Type: application/json" \
     -d '{"node_id": "<your_node_id>"}'
   ```

**详细文档：**
查看 `SKILL.md` 获取完整的 API 参考、协议规则和故障排查指南。

---

### api-gateway (API 网关)

**来源：** ClawHub (maton/api-gateway) - https://maton.ai

**功能：**
通过托管 OAuth 连接 100+ API 服务，包括：
- 📧 **邮件服务**：Outlook、Gmail、SendGrid、Mailgun
- 📊 **办公协作**：Google Workspace、Microsoft 365、Notion、Slack
- 💻 **开发工具**：GitHub、GitLab、Firebase、Netlify
- 📅 **项目管理**：Asana、Jira、Monday.com、Trello、Linear
- 👥 **CRM**：HubSpot、Salesforce、Pipedrive
- ☁️ **存储**：Google Drive、Dropbox、Box、OneDrive
- 🤖 **AI/ML**：OpenAI、Anthropic、ElevenLabs
- 💳 **支付**：Stripe、Square

**适用场景：**
- 科研协作邮件通知
- 数据同步到 Google Sheets/Airtable
- GitHub Issue/PR 自动化
- Slack/Teams 消息通知
- 云存储文件管理

**配置要求：**
- 环境变量：`MATON_API_KEY`

**快速配置：**

1. **获取 API Key**
   - 访问 https://maton.ai
   - 注册/登录账户
   - 进入 https://maton.ai/settings
   - 复制 API Key

2. **设置环境变量**
   ```bash
   export MATON_API_KEY="your-api-key-here"
   ```

3. **持久化配置**（添加到 OpenClaw 配置）
   ```json
   {
     "env": {
       "MATON_API_KEY": "your-api-key-here"
     }
   }
   ```

**使用示例：**

1. **发送邮件（Outlook）**
   ```python
   import urllib.request
   import json
   
   payload = {
       "message": {
           "subject": "研究进度更新",
           "body": {
               "contentType": "HTML",
               "content": "<html><body><h2>论文进度</h2><p>实验已完成 80%...</p></body></html>"
           },
           "toRecipients": [{"emailAddress": {"address": "collaborator@example.com"}}]
       }
   }
   
   data = json.dumps(payload).encode()
   req = urllib.request.Request(
       'https://gateway.maton.ai/outlook/v1.0/me/sendMail',
       data=data,
       method='POST'
   )
   req.add_header('Authorization', f'Bearer {MATON_API_KEY}')
   req.add_header('Content-Type', 'application/json')
   response = urllib.request.urlopen(req)
   ```

2. **读取 Google Sheets**
   ```bash
   curl https://gateway.maton.ai/google-sheets/v4/spreadsheets/SPREADSHEET_ID/values/Sheet1!A1:D10 \
     -H "Authorization: Bearer $MATON_API_KEY"
   ```

3. **创建 GitHub Issue**
   ```bash
   curl -X POST https://gateway.maton.ai/github/repos/owner/repo/issues \
     -H "Authorization: Bearer $MATON_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"title": "Bug Report", "body": "Issue description"}'
   ```

**注意事项：**
- 每个服务需要单独创建 OAuth 连接（通过 Maton 控制台）
- 速率限制：每秒 10 请求
- 支持的完整服务列表见 skill 文档

**文档：** https://github.com/maton-ai/api-gateway-skill

---

## Skills 安装指南

### 统一安装目录

**所有 Skills 应统一安装在 `~/.openclaw/skills/` 目录下**，便于 OpenClaw 自动加载和管理。

```
~/.openclaw/skills/
├── bio/                    # LabClaw 生物学技能
├── general/                # LabClaw 通用技能
├── literature/             # LabClaw 文献检索技能
├── med/                    # LabClaw 医学技能
├── pharma/                 # LabClaw 药物研发技能
├── vision/                 # LabClaw 视觉技能
├── visualization/          # LabClaw 可视化技能
├── openclaw-github-assistant/   # GitHub 管理技能
└── ...                     # 其他技能目录
```

每个技能目录应包含 `SKILL.md` 文件，OpenClaw 会自动识别并加载。

### 从 ClawHub 安装

```bash
# 搜索 Skills
clawhub search "关键词"

# 安装 Skill
clawhub install skill-name

# 安装指定版本
clawhub install skill-name --version 1.2.3

# 更新 Skill
clawhub update skill-name

# 列出已安装 Skills
clawhub list
```

### 从 URL 安装

```bash
# 下载 skill.md
curl -s https://example.com/skill.md > skills/my-skill/SKILL.md
```

---

## 推荐 Skills

| Skill | 用途 | 来源 |
|-------|------|------|
| LabClaw | 生物医学研究技能库 (240个技能) | https://github.com/wu-yc/LabClaw |
| api-gateway | 连接 100+ API（邮件、办公、开发工具） | ClawHub (maton) |
| openclaw-github-assistant | GitHub 仓库管理 | ClawHub |
| openclaw-tavily-search | AI 搜索 | ClawHub |
| multi-search-engine | 多引擎搜索 | ClawHub |
| evomap | AI Agent 市场 | https://evomap.ai |

---

## 目录结构

### 本文档目录（配置说明）

```
3.skills/
└── README.md             # 本文件（Skills 配置指南）
```

### Skills 实际安装目录

```
~/.openclaw/skills/
├── bio/                        # 生物学技能 (86个)
│   ├── anndata/SKILL.md
│   ├── scanpy/SKILL.md
│   └── ...
├── general/                    # 通用技能 (54个)
├── literature/                 # 文献检索技能 (33个)
├── med/                        # 医学技能 (22个)
├── pharma/                     # 药物研发技能 (36个)
├── vision/                     # 视觉技能 (5个)
├── visualization/              # 可视化技能 (4个)
├── api-gateway/                # API 网关技能
│   └── SKILL.md
├── openclaw-github-assistant/  # GitHub 管理
│   └── SKILL.md
└── ...                         # 其他技能
```

**注意：** Skills 统一安装在 `~/.openclaw/skills/` 目录下，而非本文档所在目录。

---

*最后更新：2026-03-27* (添加 api-gateway 技能，支持 100+ API 连接和邮件发送)
