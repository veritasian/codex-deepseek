# Codex + DeepSeek

> 一条命令搭建 OpenAI Codex CLI 与 DeepSeek 模型之间的本地协议桥。**别再手配 YAML 了 — 这个脚本帮你全部搞定。**

克隆此仓库，运行 `setup.sh`，Codex→DeepSeek 就通了。不需要 Claude。如果你恰好用 [Claude Code](https://claude.ai/code)，把它放到 `~/.claude/skills/` 里，Claude 会在你提出需求时自动运行配置。

[English](README.md) | [License](LICENSE)

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

## 文件说明

| 文件 | 用途 |
|---|---|
| `scripts/setup.sh` | 一键配置（克隆 moon-bridge → 配置 → 构建） |
| `scripts/start.sh` | 日常快速启动（启动 moon-bridge + codex） |
| `SKILL.md` | Claude Code 技能定义（可选集成） |
| `README-zh.md` | 本文档的中文版本 |

## 故障排除

| 问题 | 解决方法 |
|---|---|
| `connection refused` | Moon Bridge 未运行 — 先启动它 |
| `401` / 认证错误 | 用有效的 API Key 重新生成 `config.yml` |
| `codex: command not found` | `npm install -g @openai/codex` |
| 端口 38440 被占用 | `lsof -ti:38440 \| xargs kill` |

## 许可证

[MIT](LICENSE)
