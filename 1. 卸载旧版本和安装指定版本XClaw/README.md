# 1. 卸载旧版本和安装指定版本 XClaw

⚠️ **重要提示：本文档仅用于记录命令，请勿直接执行！** 请根据需要手动逐条执行。

---

## 版本说明

**近期较稳定的 OpenClaw 版本：2026.3.13**

> 🔴 **警告**：请勿安装最新版本（latest），可能存在兼容性问题或不稳定因素。请务必指定版本号 `2026.3.13` 进行安装。

---

## 卸载步骤

### 1. 赋予卸载脚本执行权限

```bash
chmod +x ./uninstall_openclaw.sh
```

### 2. 运行卸载脚本

```bash
./uninstall_openclaw.sh
```

此脚本将：
- 停止 OpenClaw 服务
- 卸载全局 openclaw 包
- 可选：清理配置文件（~/.openclaw/）
- 清理 npm 缓存

---

## 安装步骤

### 3. 安装指定版本 OpenClaw

```bash
npm install -g openclaw@2026.3.13
```

> ⚠️ **再次强调**：必须使用 `@2026.3.13` 指定版本号，不要省略版本号或使用 `latest`。

### 4. 初始化 OpenClaw

```bash
openclaw onboard --install-daemon
```

此命令将：
- 引导完成初始配置
- 安装系统服务（daemon）

---

## 安装飞书插件

### 5. 安装飞书集成插件

```bash
npx -y @larksuite/openclaw-lark@2026.3.17 install
```

> 注意：飞书插件版本 `2026.3.17` 与 OpenClaw 主程序版本 `2026.3.13` 是配套的。

---

## 验证安装

安装完成后，可通过以下命令验证：

```bash
# 查看版本
openclaw --version

# 查看服务状态
openclaw gateway status

# 查看已安装的插件
openclaw plugins list
```

---

## 常见问题

### Q: 为什么不能用最新版本？
A: 最新版本可能包含未测试的功能或破坏性变更。2026.3.13 是经过验证的稳定版本。

### Q: 卸载后会丢失数据吗？
A: 卸载脚本会询问是否删除配置文件。如果不删除，重新安装后可以保留之前的配置。

### Q: 安装时遇到权限错误？
A: 尝试使用 `--unsafe-perm` 参数：
```bash
npm install -g openclaw@2026.3.13 --unsafe-perm
```

---

## 相关文件

- `uninstall_openclaw.sh` - 卸载脚本

---

*最后更新：2026-03-26*
