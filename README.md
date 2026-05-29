# Codex + DeepSeek

> One script. One bridge. Codex CLI talks to DeepSeek. No YAML, no Go, no pain.

[中文](README-zh.md) | [MIT](LICENSE)

## Problem

Codex CLI v0.134+ only speaks the OpenAI Responses API (`/v1/responses`).
DeepSeek only speaks Anthropic Messages API.
They can't talk. You get `404 Not Found`.

## Solution

A script that installs and runs [Moon Bridge](https://github.com/ZhiYi-R/moon-bridge) as a local proxy. It translates Responses ↔ Anthropic so Codex and DeepSeek understand each other. One command, everything automated.

## Quickstart

```bash
git clone https://github.com/veritasian/codex-deepseek.git
bash codex-deepseek/scripts/setup.sh     # prompts for your DeepSeek API key
bash codex-deepseek/scripts/start.sh     # launches moon-bridge + codex
```

Get your API key: [platform.deepseek.com/api_keys](https://platform.deepseek.com/api_keys)

## Daily use

**Auto (one click)** — `start.sh` launches moon-bridge if it's not running, then opens Codex:

```bash
bash codex-deepseek/scripts/start.sh
```

**Manual** — start moon-bridge yourself, then run Codex:

```bash
~/moon-bridge/moonbridge --config ~/moon-bridge/config.yml &
codex
```

**Always-on** — add moon-bridge to macOS Login Items so it starts when you log in:

1. System Settings → General → Login Items & Extensions
2. Click **+** → navigate to `~/moon-bridge/moonbridge`
3. Add argument: `--config ~/moon-bridge/config.yml`

## Claude Code skill

This repo is also a [Claude Code](https://claude.ai/code) skill. Install once, then just ask Claude to set everything up:

```bash
cp -r codex-deepseek ~/.claude/skills/
```

Then in Claude Code:
```
> connect Codex to my DeepSeek API key
```
Claude will run the setup, start the bridge, and configure Codex — all in one go.

## How it works

```
Codex CLI ──Responses──→ Moon Bridge ──Anthropic──→ DeepSeek
          localhost:38440         api.deepseek.com
```

## Files

| File | Does |
|---|---|
| `scripts/setup.sh` | Installs everything (Go, moon-bridge, config, build) |
| `scripts/start.sh` | Launches moon-bridge + Codex |
| `SKILL.md` | Claude Code skill definition |

## Troubleshooting

| Problem | Fix |
|---|---|
| `connection refused` | Moon Bridge isn't running |
| `401` | Bad API key — check `~/moon-bridge/config.yml` |
| Port 38440 busy | `lsof -ti:38440 \| xargs kill` |
