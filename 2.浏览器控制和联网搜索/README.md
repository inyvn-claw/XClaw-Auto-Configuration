# 2. 浏览器控制和联网搜索

本章节介绍如何在 XClaw 中使用浏览器自动化功能。

---

## 一、浏览器控制配置

### 1.1 配置 Chrome 远程调试

为了让 XClaw 能够控制 Chrome 浏览器，需要先启用 Chrome 的远程调试功能：

**步骤：**

1. 打开 Chrome 浏览器
2. 在地址栏输入：
   ```
   chrome://inspect/#remote-debugging
   ```
3. 在打开的页面中，找到 **"Remote debugging"** 部分
4. ✅ **勾选** `Allow Remote debugging for this browser`
5. 建议同时勾选 `Open dedicated DevTools for Node`

**图示说明：**
- 访问 `chrome://inspect/#remote-debugging` 后
- 确保 **"Discover network targets"** 已启用
- 确保 **"Allow Remote debugging for this browser"** 已勾选

---

### 1.2 验证配置

配置完成后，可以通过以下方式验证：

```
chrome://inspect/#devices
```

如果看到 `Remote Target` 列表或相关调试信息，说明配置成功。

---

## 二、基本使用测试

### 2.1 启动浏览器并访问网页

**对 XClaw 发送指令：**

```
用谷歌浏览器访问 baidu.com
```

或更完整的说法：

```
用 Chrome 浏览器打开 https://www.baidu.com
```

**XClaw 会执行以下操作：**
1. 检查浏览器状态
2. 启动 Chrome（如果未运行）
3. 打开指定网址
4. 返回页面快照信息

---

### 2.2 浏览器常用操作

#### 打开网页
```
用谷歌浏览器访问 [网址]
用 Chrome 打开 https://example.com
浏览器打开 example.com
```

#### 查看页面内容
```
当前页面有什么内容？
页面显示什么？
截图看看
```

#### 点击元素
```
点击"百度一下"按钮
点击链接"新闻"
```

#### 输入文字
```
在搜索框输入"天气"
搜索"OpenClaw"
```

---

## 三、联网搜索技能

### 3.1 已安装的搜索技能

| 技能名称 | 说明 | API Key |
|---------|------|---------|
| **multi-search-engine** | 17个搜索引擎聚合（8国内+9国际） | 不需要 |
| **openclaw-tavily-search** | Tavily AI 搜索 | 需要 TAVILY_API_KEY |

---

### 3.2 使用 multi-search-engine（无需 API Key）

直接使用 `web_fetch` 工具访问搜索引擎：

**国内搜索引擎：**
```javascript
// 百度搜索
web_fetch({"url": "https://www.baidu.com/s?wd=关键词"})

// 必应中国
web_fetch({"url": "https://cn.bing.com/search?q=关键词&ensearch=0"})

// 搜狗
web_fetch({"url": "https://sogou.com/web?query=关键词"})

// 微信文章搜索
web_fetch({"url": "https://wx.sogou.com/weixin?type=2&query=关键词"})

// 今日头条
web_fetch({"url": "https://so.toutiao.com/search?keyword=关键词"})
```

**国际搜索引擎：**
```javascript
// Google
web_fetch({"url": "https://www.google.com/search?q=关键词"})

// Google 香港
web_fetch({"url": "https://www.google.com.hk/search?q=关键词"})

// DuckDuckGo（隐私搜索）
web_fetch({"url": "https://duckduckgo.com/html/?q=关键词"})

// Brave 搜索
web_fetch({"url": "https://search.brave.com/search?q=关键词"})
```

---

### 3.3 使用 Tavily 搜索（需要 API Key）

**前置条件：**
1. 在 `~/.openclaw/.env` 文件中配置：
   ```
   TAVILY_API_KEY=your_api_key_here
   ```

**使用方法：**
```bash
# 基本搜索
python3 skills/openclaw-tavily-search/scripts/tavily_search.py --query "关键词" --max-results 5 --format md

# 带回答的搜索
python3 skills/openclaw-tavily-search/scripts/tavily_search.py --query "关键词" --max-results 5 --include-answer
```

---

### 3.4 高级搜索技巧

#### 站点搜索
```javascript
// 只在 GitHub 内搜索
web_fetch({"url": "https://www.google.com/search?q=site:github.com+react"})
```

#### 文件类型搜索
```javascript
// 搜索 PDF 文件
web_fetch({"url": "https://www.google.com/search?q=机器学习+filetype:pdf"})
```

#### 时间过滤（Google）
```javascript
// 最近一周
web_fetch({"url": "https://www.google.com/search?q=AI新闻&tbs=qdr:w"})

// 最近一天
web_fetch({"url": "https://www.google.com/search?q=AI新闻&tbs=qdr:d"})
```

#### DuckDuckGo Bangs 快捷方式
```javascript
// !gh = 直达 GitHub
web_fetch({"url": "https://duckduckgo.com/html/?q=!gh+tensorflow"})

// !so = 直达 Stack Overflow
web_fetch({"url": "https://duckduckgo.com/html/?q=!so+python"})

// !w = 直达 Wikipedia
web_fetch({"url": "https://duckduckgo.com/html/?q=!w+人工智能"})
```

#### WolframAlpha 知识计算
```javascript
// 汇率换算
web_fetch({"url": "https://www.wolframalpha.com/input?i=100+USD+to+CNY"})

// 数学计算
web_fetch({"url": "https://www.wolframalpha.com/input?i=integrate+x^2+dx"})

// 天气查询
web_fetch({"url": "https://www.wolframalpha.com/input?i=weather+in+Beijing"})
```

---

## 四、故障排查

### 4.1 浏览器无法启动

**问题：** XClaw 无法启动 Chrome

**解决方案：**
1. 确认 Chrome 已安装
2. 检查远程调试配置（见 1.1）
3. 尝试手动启动 Chrome 并启用调试端口：
   ```bash
   google-chrome --remote-debugging-port=9222
   ```

### 4.2 网页访问失败

**问题：** `web_fetch` 返回错误或空内容

**可能原因：**
- 网络连接问题
- 网站有反爬虫机制
- 网站返回 JavaScript 渲染的页面

**解决方案：**
- 使用浏览器工具代替 `web_fetch`
- 尝试不同的搜索引擎
- 检查网络连接

### 4.3 搜索技能报错

**Tavily 搜索报错：**
- 检查 `~/.openclaw/.env` 中是否正确配置了 `TAVILY_API_KEY`
- 确认 API Key 有效且未过期

---

## 五、实用示例

### 示例 1：搜索并访问结果

```
用户：帮我搜索"OpenClaw 教程"
XClaw：使用 Tavily 搜索...
用户：打开第一个结果
XClaw：用谷歌浏览器访问 [链接]
```

### 示例 2：对比搜索结果

```
用户：在百度和 Google 搜索"AI新闻"
XClaw：
- web_fetch 百度搜索结果
- web_fetch Google 搜索结果
- 对比展示
```

### 示例 3：获取网页截图

```
用户：访问 news.baidu.com 并截图
XClaw：
1. 打开浏览器
2. 访问网址
3. 使用 browser screenshot 命令截图
```

---

## 六、相关文件

本目录用于存放：
- 浏览器配置文件
- 搜索脚本示例
- 自定义搜索工具

---

## 七、修复 Web Search 配置

⚠️ **重要提示：本节仅用于记录配置步骤，请勿直接执行命令！** 请根据需要手动操作。

### 7.1 安装搜索 Skills

需要安装以下两个搜索技能：

| 技能 | ClawHub 链接 |
|------|-------------|
| **openclaw-tavily-search** | https://clawhub.ai/jacky1n7/openclaw-tavily-search |
| **multi-search-engine** | https://clawhub.ai/gpyangyoujun/multi-search-engine |

**安装命令：**
```bash
clawhub install openclaw-tavily-search
clawhub install multi-search-engine
```

### 7.2 配置 Tavily API Key

**步骤 1：获取 API Key**
- 访问 https://app.tavily.com/
- 注册/登录账号
- 在 Dashboard 中生成 API Key

**步骤 2：保存到 .env 文件**

编辑或创建 `~/.openclaw/.env` 文件：
```bash
# ~/.openclaw/.env
TAVILY_API_KEY=tvly-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

> 🔴 **安全提醒**：请勿将包含真实 API Key 的 .env 文件提交到 Git 仓库！

### 7.3 修改 OpenClaw 配置文件

编辑 `~/.openclaw/openclaw.json`，进行以下修改：

```json
{
  "tools": {
    "profile": "full",
    "web": {
      "search": {
        "enabled": false
      }
    }
  }
}
```

**关键配置说明：**
- `tools.profile`: 设置为 `"full"` 启用完整工具集
- `tools.web.search.enabled`: 设置为 `false` 关闭默认的 web search（避免冲突）

### 7.4 配置 TOOLS.md

在 workspace 目录创建或编辑 `TOOLS.md`：

```markdown
# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics - the stuff that's unique to your setup.

## Web Search

Use the openclaw-tavily-search skill as the top-priority search tool when doing web search.

If the question requires searching for more relevant knowledge, use multi-search-engine skill as an alternative solution.
```

### 7.5 测试搜索功能

配置完成后，可以测试以下指令：

```
用 multi-search-engine 搜索无锡4月1-6日的城市活动，把每个搜索引擎的结果都告诉我
```

**预期结果：**
XClaw 应该使用 multi-search-engine skill，通过多个搜索引擎（百度、必应、Google 等）搜索相关信息，并汇总展示各个引擎的结果。

### 7.6 故障排查

**问题：Tavily 搜索返回错误**
- 检查 `~/.openclaw/.env` 中 `TAVILY_API_KEY` 是否正确
- 确认 API Key 未过期
- 检查网络连接是否能访问 tavily.com

**问题：multi-search-engine 无法使用**
- 确认 skill 已正确安装：`clawhub list`
- 检查 `web_fetch` 工具是否可用
- 尝试直接访问搜索引擎 URL 测试网络

**问题：默认 web search 干扰**
- 确认 `openclaw.json` 中 `tools.web.search.enabled` 已设置为 `false`
- 重启 OpenClaw 服务使配置生效

---

*最后更新：2026-03-26*
