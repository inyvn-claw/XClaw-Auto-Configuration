# MEMORY.md - 科研助手 Researcher 记忆

## 重要提醒

### 邮件发送避免乱码（2026-03-02）
**问题：** HTML 内容被 URL 编码，显示为 `%3Cdiv...`

**解决方案：** 
- 不要使用 shell 脚本中的 URL 编码
- 使用 Python 直接读取 HTML 文件并发送
- 使用 `json.dumps(payload, ensure_ascii=False)` 保留中文

**正确示例：**
```python
import json

with open('email_content.html', 'r') as f:
    html_content = f.read()

payload = {
    "message": {
        "subject": "[AGI&FBHC科研热点推送] LLM智能体(Agent)前沿进展",
        "body": {
            "contentType": "HTML",
            "content": html_content  # 直接使用原始 HTML
        },
        "toRecipients": [{"emailAddress": {"address": "xxx@xxx.com"}}]
    }
}

# 发送
cmd = [
    'curl', '-s', '-X', 'POST',
    '-H', f'Authorization: Bearer {api_key}',
    '-H', 'Content-Type: application/json',
    '-d', json.dumps(payload, ensure_ascii=False),
    'https://gateway.maton.ai/outlook/v1.0/me/sendMail'
]
```

**避免的做法：**
```bash
# ❌ 错误：这样会 URL 编码
HTML_CONTENT=$(cat file.html | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")
```
