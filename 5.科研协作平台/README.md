# 5. 科研协作平台部署指南

> 项目地址：https://github.com/inyvn-claw/research-platform

---

## 项目简介

这是一个面向科研团队的协作平台，用于管理研究项目、共享文献资料、协调实验进度等。

**目标用户：** 科研团队、实验室成员、研究助理

**主要功能：**
- 项目管理与任务分配
- 文献资料共享与管理
- 实验进度跟踪
- 团队协作与沟通

---

## 部署环境要求

### 系统要求
- **操作系统：** Linux (Ubuntu 20.04+ 推荐) / macOS / Windows (WSL2)
- **内存：** 至少 4GB RAM
- **存储：** 至少 20GB 可用空间
- **网络：** 可访问 GitHub 和必要的软件源

### 软件依赖
- **Node.js：** v18.x 或更高版本
- **npm / pnpm：** 包管理器
- **Git：** 版本控制
- **Docker：** （可选）用于容器化部署
- **Nginx / Apache：** （可选）反向代理

---

## 部署步骤

### 1. 环境准备

#### 1.1 安装 Node.js
```bash
# 使用 nvm 安装（推荐）
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20

# 验证安装
node -v  # 应显示 v20.x.x
npm -v   # 应显示 10.x.x
```

#### 1.2 安装 pnpm（可选但推荐）
```bash
npm install -g pnpm
pnpm -v
```

#### 1.3 安装 Git
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y git

# macOS
brew install git

# 验证安装
git --version
```

---

### 2. 获取项目代码

#### 2.1 创建工作目录
```bash
mkdir -p ~/Documents/Github
cd ~/Documents/Github
```

#### 2.2 克隆仓库
```bash
# 使用 HTTPS
git clone https://github.com/inyvn-claw/research-platform.git

# 或使用 SSH（需配置 SSH Key）
git clone git@github.com:inyvn-claw/research-platform.git
```

#### 2.3 进入项目目录
```bash
cd research-platform
```

---

### 3. 安装依赖

#### 3.1 使用 npm 安装
```bash
npm install
```

#### 3.2 或使用 pnpm 安装（推荐）
```bash
pnpm install
```

---

### 4. 环境配置

#### 4.1 复制环境变量模板
```bash
cp .env.example .env
```

#### 4.2 编辑环境变量
```bash
nano .env  # 或使用其他编辑器：vim / code .
```

**常用环境变量配置：**
```env
# 基础配置
NODE_ENV=production
PORT=3000
HOST=0.0.0.0

# 数据库配置（如使用）
DATABASE_URL=postgresql://user:password@localhost:5432/research_platform
# 或
DATABASE_URL=sqlite://./data/database.sqlite

# 认证配置
JWT_SECRET=your-secret-key-here
SESSION_SECRET=your-session-secret-here

# API 密钥（如需）
OPENAI_API_KEY=your-openai-api-key
ANTHROPIC_API_KEY=your-anthropic-api-key

# 外部服务配置
REDIS_URL=redis://localhost:6379
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
```

---

### 5. 数据库初始化（如适用）

#### 5.1 如果使用 Prisma ORM
```bash
npx prisma migrate dev
npx prisma generate
```

#### 5.2 如果使用其他 ORM
```bash
# 根据项目文档执行数据库迁移
npm run db:migrate
# 或
npm run db:push
```

#### 5.3 种子数据（可选）
```bash
npm run db:seed
```

---

### 6. 构建项目

#### 6.1 开发环境构建
```bash
npm run build
# 或
pnpm build
```

#### 6.2 生产环境构建
```bash
npm run build:prod
# 或
NODE_ENV=production npm run build
```

---

### 7. 启动服务

#### 7.1 开发模式
```bash
npm run dev
# 或
pnpm dev
```

服务启动后，访问：http://localhost:3000

#### 7.2 生产模式
```bash
npm start
# 或
npm run start:prod
```

#### 7.3 使用 PM2 进程管理（推荐用于生产）
```bash
# 全局安装 PM2
npm install -g pm2

# 启动服务
pm2 start npm --name "research-platform" -- start

# 查看状态
pm2 status

# 保存配置
pm2 save

# 设置开机自启
pm2 startup
```

---

### 8. 配置 Nginx 反向代理（可选但推荐）

#### 8.1 安装 Nginx
```bash
# Ubuntu/Debian
sudo apt install -y nginx

# 验证安装
nginx -v
```

#### 8.2 创建 Nginx 配置文件
```bash
sudo nano /etc/nginx/sites-available/research-platform
```

**配置示例：**
```nginx
server {
    listen 80;
    server_name your-domain.com;  # 替换为你的域名或服务器 IP

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # 静态文件缓存（如适用）
    location /_next/static {
        alias /path/to/research-platform/.next/static;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### 8.3 启用配置
```bash
sudo ln -s /etc/nginx/sites-available/research-platform /etc/nginx/sites-enabled/
sudo nginx -t  # 测试配置
sudo systemctl restart nginx
```

---

### 9. 配置 HTTPS（可选但推荐）

#### 9.1 使用 Certbot 获取 SSL 证书
```bash
# 安装 Certbot
sudo apt install -y certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d your-domain.com

# 自动续期测试
sudo certbot renew --dry-run
```

---

### 10. 配置防火墙（安全建议）

```bash
# Ubuntu/Debian 使用 UFW
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable

# 查看状态
sudo ufw status
```

---

## Docker 部署（可选）

如果项目包含 Dockerfile，可以使用 Docker 部署：

### 1. 构建镜像
```bash
docker build -t research-platform .
```

### 2. 运行容器
```bash
docker run -d \
  --name research-platform \
  -p 3000:3000 \
  -v $(pwd)/data:/app/data \
  --env-file .env \
  research-platform
```

### 3. 使用 Docker Compose（如适用）
```bash
# 启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

---

## 更新与维护

### 更新代码
```bash
cd ~/Documents/Github/research-platform
git pull origin main  # 或 master

# 重新安装依赖（如 package.json 有变化）
npm install

# 重新构建
npm run build

# 重启服务（如使用 PM2）
pm2 restart research-platform
```

### 备份数据
```bash
# 备份数据库（如使用 SQLite）
cp data/database.sqlite data/database.sqlite.backup.$(date +%Y%m%d)

# 备份上传的文件
tar -czvf uploads-backup-$(date +%Y%m%d).tar.gz uploads/
```

### 查看日志
```bash
# 使用 PM2
pm2 logs research-platform

# 使用 Docker
docker logs -f research-platform

# 直接查看
 tail -f logs/app.log
```

---

## 故障排查

### 常见问题

#### 1. 端口被占用
```bash
# 查找占用 3000 端口的进程
lsof -i :3000

# 终止进程
kill -9 <PID>

# 或修改项目端口
export PORT=3001
```

#### 2. 权限不足
```bash
# 修复文件权限
chmod -R 755 ~/Documents/Github/research-platform

# 或使用 sudo（不推荐长期使用）
sudo npm start
```

#### 3. 内存不足
```bash
# 增加 Node.js 内存限制
node --max-old-space-size=4096 ./node_modules/.bin/next start
```

#### 4. 数据库连接失败
- 检查数据库服务是否运行
- 验证 DATABASE_URL 环境变量
- 检查防火墙设置

---

## OpenClaw 集成配置

如需在 OpenClaw 中调用该平台的 API：

### 1. 添加环境变量到 OpenClaw
```bash
# 编辑 OpenClaw 配置
nano ~/.openclaw/openclaw.json
```

### 2. 添加平台配置
```json
{
  "research-platform": {
    "url": "http://localhost:3000",
    "apiKey": "your-platform-api-key",
    "webhookSecret": "your-webhook-secret"
  }
}
```

### 3. 重启 OpenClaw
```bash
openclaw gateway restart
```

---

## 目录结构参考

```
~/Documents/Github/research-platform/
├── .env                    # 环境变量（需手动创建）
├── .env.example            # 环境变量模板
├── .git/                   # Git 版本控制
├── README.md               # 项目说明文档
├── package.json            # 项目依赖
├── src/                    # 源代码
├── public/                 # 静态资源
├── data/                   # 数据文件（如 SQLite）
├── uploads/                # 上传文件目录
├── logs/                   # 日志文件
├── docker-compose.yml      # Docker 配置（如适用）
└── Dockerfile              # Docker 镜像配置（如适用）
```

---

## 参考资料

- 项目 README：https://github.com/inyvn-claw/research-platform/blob/main/README.md
- Node.js 官方文档：https://nodejs.org/docs/
- PM2 文档：https://pm2.keymetrics.io/docs/
- Nginx 文档：https://nginx.org/en/docs/

---

*最后更新：2026-03-27*
