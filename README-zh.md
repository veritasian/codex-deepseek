# Codex + DeepSeek

> 一个脚本，一座桥。Codex CLI 直连 DeepSeek。告别 YAML，告别折腾。

[English](README.md) | [MIT](LICENSE)

## 这是什么

连接 Codex 和 DeepSeek 的官方方式是 DeepSeek 团队的[这篇指南](https://github.com/deepseek-ai/awesome-deepseek-agent/blob/main/docs/codex.md)。方法可行，但步骤很长：装 Go、克隆 Moon Bridge、手写 config.yml、用命令行参数生成 Codex 配置、自己管理代理进程。对只想"能用就行"的人来说，太折腾了。

这个仓库把所有这些变成了**一条脚本**。同样的结果，不需要工程背景。DIY 精神，一键完成。

## 问题

Codex CLI v0.134+ 只认 OpenAI Responses API（`/v1/responses`）。
DeepSeek 只认 Anthropic Messages API。
彼此无法通信。直接连接返回 `404 Not Found`。

## 解决方案

一个脚本安装并运行 [Moon Bridge](https://github.com/ZhiYi-R/moon-bridge) 作为本地代理。将 Responses 翻译为 Anthropic，Codex 和 DeepSeek 就能互相理解。一条命令，全部自动完成。

## 快速开始

```bash
git clone https://github.com/veritasian/codex-deepseek.git
bash codex-deepseek/scripts/setup.sh     # 会提示输入 DeepSeek API Key
bash codex-deepseek/scripts/start.sh     # 启动 moon-bridge + Codex
```

API Key 获取：[platform.deepseek.com/api_keys](https://platform.deepseek.com/api_keys)

## 日常使用

**自动（一键）** — `start.sh` 自动检测并启动 moon-bridge，然后打开 Codex：

```bash
bash codex-deepseek/scripts/start.sh
```

**手动** — 自己启动 moon-bridge，再运行 Codex：

```bash
~/moon-bridge/moonbridge --config ~/moon-bridge/config.yml &
codex
```

**开机自启** — 将 moon-bridge 添加到 macOS 登录项：

1. 系统设置 → 通用 → 登录项与扩展
2. 点击 **+** → 找到 `~/moon-bridge/moonbridge`
3. 添加参数：`--config ~/moon-bridge/config.yml`

## Claude Code 技能

本仓库也是一个 [Claude Code](https://claude.ai/code) 技能。安装后直接用自然语言让 Claude 配置一切：

```bash
cp -r codex-deepseek ~/.claude/skills/
```

然后在 Claude Code 里说：
```
> 帮我把 Codex 连接到 DeepSeek
```
Claude 会自动运行配置、启动桥接、设置 Codex。

## 工作原理

```
Codex CLI ──Responses──→ Moon Bridge ──Anthropic──→ DeepSeek
          localhost:38440         api.deepseek.com
```

## 文件说明

| 文件 | 用途 |
|---|---|
| `scripts/setup.sh` | 安装一切（Go、moon-bridge、配置、编译） |
| `scripts/start.sh` | 启动 moon-bridge + Codex |
| `SKILL.md` | Claude Code 技能定义 |

## 故障排除

| 问题 | 解决 |
|---|---|
| `connection refused` | Moon Bridge 未启动 |
| `401` | API Key 有误 — 检查 `~/moon-bridge/config.yml` |
| 端口 38440 占用 | `lsof -ti:38440 \| xargs kill` |
