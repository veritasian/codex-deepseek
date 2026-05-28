# Codex + DeepSeek — Claude Code 技能

> 一个 [Claude Code](https://claude.ai/code) 技能，在 OpenAI Codex CLI 与 DeepSeek 模型之间搭建本地协议桥。**别再手配 YAML 了——让 Claude 搞定。**

这是一个 **Claude Code 技能**。安装到 `~/.claude/skills/` 后，当你需要将 Codex 连接到 DeepSeek 时，Claude 会自动触发此技能并为你运行配置。如果你不用 Claude Code，脚本也可以独立运行——但你会失去自动触发和引导式配置的体验。

[English](README.md) | [License](LICENSE)

## 思维方式

这个技能体现了一套解决 AI 工具"协议不匹配"问题的通用范式：

1. **找到差距** — Codex 使用 Responses API，DeepSeek 使用 Anthropic Messages API。它们永远无法直接通信。
2. **找到翻译层** — Moon Bridge 位于中间，在两种协议之间转换请求。
3. **自动化连接** — 这个技能不只是记录修复方法；它执行整个配置流程：克隆、配置、构建、启动。

你可以将同样的思路应用到任何两个使用不同协议的工具上：找到本地代理，自动化配置。别花几个小时手写 YAML，Claude 几秒钟就能搞定。

## 问题

Codex CLI v0.134+ 放弃了 Chat Completions API 支持，只使用 OpenAI Responses API（`/v1/responses`）。DeepSeek 不提供 `/v1/responses` 端点——它使用兼容 Anthropic 的 Messages API。直接请求会返回 `404 Not Found`。

Moon Bridge 作为本地代理，将 Responses API 调用翻译为 DeepSeek 能接受的 Anthropic 格式请求。你的 API Key 不会离开你的机器。

## 功能特性

- **Claude 驱动配置** — 描述你的需求，Claude 运行技能
- **一条命令** — 克隆、配置、构建、启动，一气呵成
- **自动安装依赖** — 通过 Homebrew 安装 Go、Node、Codex CLI（macOS）
- **安全** — API Key 输入隐藏，配置文件 `chmod 600`
- **幂等** — 可重复运行；跳过已完成的步骤
- **零云依赖** — 完全运行在本地，无需第三方代理

## 快速开始

### 使用 Claude Code

```
你：帮我把 Codex 连接到 DeepSeek
Claude：[触发此技能，运行 setup.sh，完成]
你：codex
```

### 不使用 Claude Code

```bash
# 1. 运行配置脚本（会提示你输入 DeepSeek API Key）
bash scripts/setup.sh

# 2. 启动 Codex — moon-bridge 会自动启动
bash scripts/start.sh
```

在 [platform.deepseek.com/api_keys](https://platform.deepseek.com/api_keys) 获取你的 API Key。

## 工作原理

```
Codex CLI                  Moon Bridge                 DeepSeek API
─────────                  ───────────                 ────────────
Responses API ───────────→ Transform 模式 ───────────→ Anthropic API
/v1/responses   localhost:38440    /v1/responses →     api.deepseek.com/anthropic
```

## 环境要求

- macOS（Linux 支持即将推出）
- [Claude Code](https://claude.ai/code)（用于自动触发技能）
- [Homebrew](https://brew.sh)（用于自动安装依赖）

其他依赖（Go、Node、Codex CLI）如果缺失，`setup.sh` 会自动安装。

## 手动使用

配置完成后，先启动 moon-bridge 再启动 Codex：

```bash
~/moon-bridge/moonbridge --config ~/moon-bridge/config.yml &
codex
```

## 安装为 Claude Code 技能

```bash
git clone https://github.com/veritasian/codex-deepseek.git
cp -r codex-deepseek ~/.claude/skills/
```

当你在 Claude Code 中提到连接 Codex 到 DeepSeek、用非 OpenAI 模型运行 Codex、或遇到 AI 工具之间的协议错误时，Claude 会自动检测到这个技能。

## 文件说明

| 文件 | 用途 |
|---|---|
| `SKILL.md` | Claude Code 技能定义（触发条件 + 使用说明） |
| `scripts/setup.sh` | 一键配置脚本（克隆 → 配置 → 构建 → 启动） |
| `scripts/start.sh` | 日常快速启动（moon-bridge + codex） |
| `README-zh.md` | 本文档的中文翻译 |

## 故障排除

| 问题 | 解决方法 |
|---|---|
| `connection refused` | Moon Bridge 未运行 — 先启动它 |
| `401` / 认证错误 | 用有效的 API Key 重新生成 `config.yml` |
| `codex: command not found` | `npm install -g @openai/codex` |
| 端口 38440 被占用 | `lsof -ti:38440 \| xargs kill` |

## 许可证

[MIT](LICENSE)
