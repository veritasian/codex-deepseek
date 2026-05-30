# Codex + DeepSeek — 一键脚本桥接

> 想用 Codex CLI，但不想付 OpenAI 的账单？DeepSeek 更便宜更快——但两者协议完全不同。这个仓库给你一条脚本，自动搭桥、写配置、启动一切。CLI 的能力，DeepSeek 的价格，零手动。

[![Stars](https://img.shields.io/github/stars/veritasian/codex-deepseek)](https://github.com/veritasian/codex-deepseek/stargazers)
[![License](https://img.shields.io/github/license/veritasian/codex-deepseek)](LICENSE)

[English](README.md)

## 痛点

你想用 Codex CLI——终端原生、通过 OAuth 免费使用。但它只能连接 OpenAI 的模型。DeepSeek V4 质量相当，成本却只有 OpenAI 零头。问题来了：Codex 使用 **Responses API**，DeepSeek 使用 **Anthropic Messages API**。它们根本无法通信。你只会得到 `404 Not Found`。

官方 DeepSeek 指南一步一步教你手动修复——安装 Go、克隆 Moon Bridge、手写 `config.yml`、用命令行生成配置、管理后台代理。可行，但需要 20 多分钟和各种 YAML 折腾。

## 解决方案

**一条脚本，从头到尾。** 克隆这个仓库，运行 `setup.sh`，Codex→DeepSeek 就通了。脚本处理每一步：检查环境（Go、Node、Codex CLI）、克隆 Moon Bridge、用你的 API Key 写配置、编译二进制文件、生成 `~/.codex/config.toml`、在后台启动代理。

## 快速开始

```bash
git clone https://github.com/veritasian/codex-deepseek.git
bash codex-deepseek/scripts/setup.sh     # 会提示输入 DeepSeek API Key
bash codex-deepseek/scripts/start.sh     # 启动 moon-bridge + codex
```

**获取 API Key：** [platform.deepseek.com/api_keys](https://platform.deepseek.com/api_keys)

## 工作原理

```
Codex CLI ──Responses API──→ Moon Bridge ──Anthropic API──→ DeepSeek
          localhost:38440      (本地代理)       api.deepseek.com
```

| 步骤 | 脚本做什么 |
|---|---|
| 1. 环境检查 | 检查 Go、Node、Codex CLI。缺失的通过 Homebrew 安装。 |
| 2. Moon Bridge | 从 GitHub 克隆（已有则 `git pull` 更新） |
| 3. 配置 | 写入 `~/moon-bridge/config.yml`，API Key 权限设为 `chmod 600` |
| 4. 编译 | `go build` 构建 moonbridge 二进制文件 |
| 5. Codex | 备份现有 `~/.codex/config.toml`，生成指向桥接的新配置 |
| 6. 启动 | 在后台启动 moonbridge，端口 38440，Codex 随时可用 |

## 日常使用

**一键自动：**
```bash
bash codex-deepseek/scripts/start.sh
```

**手动：**
```bash
~/moon-bridge/moonbridge --config ~/moon-bridge/config.yml &
codex
```

**开机自启：**
系统设置 → 通用 → 登录项 → `+` → `~/moon-bridge/moonbridge` — 添加参数: `--config ~/moon-bridge/config.yml`

## 附赠：Claude Code 技能

这个仓库包含 `SKILL.md`。安装后 Claude 用自然语言就能完成所有配置：

```bash
cp -r codex-deepseek ~/.claude/skills/
```
```
> 帮我把 Codex 连接到 DeepSeek
```

## 文件说明

| 文件 | 用途 |
|---|---|
| `scripts/setup.sh` | 完整配置：克隆 → 配置 → 编译 → 启动 |
| `scripts/start.sh` | 快速启动：自动检测并启动 moon-bridge，打开 Codex |
| `SKILL.md` | Claude Code 技能定义 |

## 灵感来源

本项目基于 DeepSeek 官方的 [Codex + DeepSeek 集成指南](https://github.com/deepseek-ai/awesome-deepseek-agent/blob/main/docs/codex.md)。原指南需要手动安装 Go、克隆 Moon Bridge、手写 `config.yml`、用 CLI 生成配置、自行管理代理进程。这个仓库将同样的步骤封装为一条脚本。

## 故障排除

| 症状 | 解决方法 |
|---|---|
| `connection refused` | Moon Bridge 未启动 |
| `401 Unauthorized` | API Key 有误 — 检查 `~/moon-bridge/config.yml` |
| 端口 38440 占用 | `lsof -ti:38440 \| xargs kill` |
| `codex: command not found` | `npm install -g @openai/codex` |

## 许可证

[MIT](LICENSE)
