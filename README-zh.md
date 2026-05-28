# Codex + DeepSeek

> 一条命令搭建 OpenAI Codex CLI 与 DeepSeek 模型之间的本地协议桥。**别再手配 YAML 了 — 这个脚本帮你全部搞定。**

克隆此仓库，运行 `setup.sh`，Codex→DeepSeek 就通了。不需要 Claude。如果你恰好用 [Claude Code](https://claude.ai/code)，把它放到 `~/.claude/skills/` 里，Claude 会在你提出需求时自动运行配置。

[English](README.md) | [License](LICENSE)

## 灵感来源

本项目基于 DeepSeek 团队的官方[《Codex + DeepSeek 集成指南》](https://github.com/deepseek-ai/awesome-deepseek-agent/blob/main/docs/codex.md)。原指南需要手动安装 Go、克隆 Moon Bridge、手写 `config.yml`、通过 CLI 参数生成 Codex 配置、自行管理代理进程——对非技术背景的用户来说门槛不低。

这个仓库把每一步都封装进了**一条脚本**，你不需要懂工程也能搞定。如果原指南是技术文档，这就是一键安装包。

## 思维方式

这个仓库展示了一套解决 AI 工具"协议不匹配"问题的通用范式：

1. **找到差距** — Codex 使用 Responses API，DeepSeek 使用 Anthropic Messages API。它们永远无法直接通信。
2. **找到翻译层** — Moon Bridge 位于中间，在两种协议之间转换请求。
3. **自动化连接** — 不只是记录修复方法，而是把整个配置流程脚本化：克隆、配置、构建、启动。

将同样的思路应用到任何两个使用不同协议的工具上：找到本地代理，自动化配置。别花几个小时手写 YAML，一个脚本几秒钟就能搞定。

## 问题

Codex CLI v0.134+ 放弃了 Chat Completions API 支持，只使用 OpenAI Responses API（`/v1/responses`）。DeepSeek 不提供 `/v1/responses` 端点——它使用兼容 Anthropic 的 Messages API。直接请求会返回 `404 Not Found`。

Moon Bridge 作为本地代理，将 Responses API 调用翻译为 DeepSeek 能接受的 Anthropic 格式请求。你的 API Key 不会离开你的机器。

## 功能特性

- **一条命令** — 克隆、配置、构建、启动，一气呵成
- **自动安装依赖** — 通过 Homebrew 安装 Go、Node、Codex CLI（macOS）
- **安全** — API Key 输入隐藏，配置文件 `chmod 600`
- **幂等** — 可重复运行；跳过已完成的步骤
- **零云依赖** — 完全运行在本地，无需第三方代理

## 快速开始

```bash
# 1. 克隆并运行配置（会提示输入 DeepSeek API Key）
git clone https://github.com/veritasian/codex-deepseek.git
bash codex-deepseek/scripts/setup.sh

# 2. 配置完成后，启动 Codex — moon-bridge 自动启动
bash codex-deepseek/scripts/start.sh
```

在 [platform.deepseek.com/api_keys](https://platform.deepseek.com/api_keys) 获取 API Key。

## 日常使用（配置完成后）

`setup.sh` 构建好 moon-bridge 后，就不再需要这个仓库了。每次只需启动 moon-bridge，然后运行 Codex：

```bash
# 方式 A：使用自带的启动脚本
bash codex-deepseek/scripts/start.sh

# 方式 B：手动启动
~/moon-bridge/moonbridge --config ~/moon-bridge/config.yml &
codex
```

## 工作原理

```
Codex CLI                  Moon Bridge                 DeepSeek API
─────────                  ───────────                 ────────────
Responses API ───────────→ Transform 模式 ───────────→ Anthropic API
/v1/responses   localhost:38440    /v1/responses →     api.deepseek.com/anthropic
```

## 环境要求

- macOS（Linux 支持即将推出）
- [Homebrew](https://brew.sh)（用于自动安装依赖）

其他依赖（Go、Node、Codex CLI）如果缺失，`setup.sh` 会自动安装。

## 附赠：Claude Code 技能

本仓库包含 `SKILL.md` — 如果你使用 [Claude Code](https://claude.ai/code)，可以将其安装为技能：

```bash
cp -r codex-deepseek ~/.claude/skills/
```

Claude 会在你提到连接 Codex 到 DeepSeek 时自动检测并运行配置。脚本本身完全独立工作，不需要 Claude — 技能只是锦上添花的便利层。

## 桌面应用

更喜欢图形界面？**[Moon Bridge App](https://github.com/veritasian/moonbridge-app)** 是一个原生 macOS 应用，把 Go 二进制文件封装进了点击即用的界面：

- 从侧边栏选择提供商（DeepSeek、OpenRouter、Groq、Ollama）
- 粘贴你的 API Key
- 点击 **启动**

不需要终端，不需要 YAML，不需要任何技术背景。基于 SwiftUI 构建，底层使用同一个 Moon Bridge Go 二进制文件。

```bash
git clone https://github.com/veritasian/moonbridge-app.git
cd moonbridge-app && bash build.sh
open "build/Moon Bridge.app"
```

## 文件说明

| 文件 | 用途 |
|---|---|
| `scripts/setup.sh` | 一键配置（克隆 moon-bridge → 配置 → 构建） |
| `scripts/start.sh` | 日常快速启动（启动 moon-bridge + codex） |
| `SKILL.md` | Claude Code 技能定义（可选集成） |
| `README-zh.md` | 本文档的中文版本 |

## 其他桥接方案

本仓库使用 Moon Bridge 作为翻译层，但不是唯一选择。以下是另外 5 个能将 Codex CLI 连接到自定义 LLM 的桥接工具——各有取舍。全部都可以通过 Claude Code 触发配置。

| 桥接工具 | 方式 | 最适合 | 安装 |
|---|---|---|---|
| **[CCS](https://github.com/kaitranntt/ccs)** | 配置管理器 + 内置代理。`ccs codex "提示词"` 即可用任意提供商启动 Codex。通过 OpenRouter 支持 300+ 模型，支持 OAuth。仪表盘在 `localhost:3000`。 | 无需改配置文件即可随时切换提供商 | `npm install -g @kaitranntt/ccs` |
| **[codex-relay](https://github.com/MetaFARS/codex-relay)** | 轻量 Rust 代理。专为 Codex 打造——翻译 Responses API → Chat Completions。自动生成 Codex 配置。 | 极简、快速、单一用途 | `cargo install codex-relay` |
| **[Nyro](https://github.com/nyroway/nyro)** | 通用网关 + 桌面应用。完整协议翻译（Anthropic ↔ OpenAI ↔ Gemini）。语义缓存，一键 CLI 配置同步。 | 图形界面 + 缓存 + 多协议 | 桌面应用或二进制文件 |
| **[Lynkr](https://www.npmjs.com/package/lynkr)** | 一条命令的 npm 代理。支持 Codex、Claude Code、Cursor、Cline。Token 优化（节省 60-80%），基于复杂度自动路由。Apache 2.0。 | 快速安装，节省 Token | `npm install -g lynkr` |
| **[CCRelay](https://github.com/inflaborg/ccrelay)** | VS Code 扩展 + 本地代理。同一端口支持 Anthropic、OpenAI Chat 和 Responses API。配置热加载、Web 仪表盘、中英文界面。 | VS Code 用户、中文界面 | VS Code 插件市场 |

### 如何通过 Claude Code 使用任何桥接工具

本仓库的思路适用于以上所有方案：

1. **安装桥接工具** — 按照其安装命令操作
2. **将 Codex 指向它** — 在 `~/.codex/config.toml` 中将 `base_url` 设为该桥接工具的本地地址
3. **让 Claude 帮你配置** — 如果你有 Claude Code，说"帮我把 Codex 通过 CCS 连接到 DeepSeek"，Claude 会逐步引导完成配置

每个桥接工具解决的是同一个核心问题（Codex 使用 Responses API，你的 LLM 不用）——选择最符合你使用习惯和工具链的那一个。

## 故障排除

| 问题 | 解决方法 |
|---|---|
| `connection refused` | Moon Bridge 未运行 — 先启动它 |
| `401` / 认证错误 | 用有效的 API Key 重新生成 `config.yml` |
| `codex: command not found` | `npm install -g @openai/codex` |
| 端口 38440 被占用 | `lsof -ti:38440 \| xargs kill` |

## 许可证

[MIT](LICENSE)
