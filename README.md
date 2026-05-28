# Codex + DeepSeek

Connect [OpenAI Codex CLI](https://github.com/openai/codex) to [DeepSeek](https://deepseek.com) models via [Moon Bridge](https://github.com/ZhiYi-R/moon-bridge).

## Problem

Codex CLI v0.134+ dropped Chat Completions API support and only speaks the OpenAI Responses API (`/v1/responses`). DeepSeek doesn't offer a `/v1/responses` endpoint — it uses an Anthropic-compatible Messages API. Direct requests return `404 Not Found`.

Moon Bridge runs as a local proxy that translates Responses API calls into Anthropic-format requests that DeepSeek accepts. Your API key never leaves your machine.

## Features

- **One command** — clones, configures, builds, and launches everything
- **Auto-installs prerequisites** — Go, Node, Codex CLI via Homebrew (macOS)
- **Secure** — API key prompt with hidden input, stored `chmod 600`
- **Idempotent** — safe to re-run; skips completed steps
- **Zero cloud dependency** — runs entirely on localhost, no third-party proxy

## Quickstart

```bash
# 1. Run setup (prompts for your DeepSeek API key)
bash scripts/setup.sh

# 2. Launch Codex — moon-bridge starts automatically
bash scripts/start.sh
```

Get your API key at [platform.deepseek.com/api_keys](https://platform.deepseek.com/api_keys).

## How it works

```
Codex CLI                  Moon Bridge                 DeepSeek API
─────────                  ───────────                 ────────────
Responses API ───────────→ Transform mode ───────────→ Anthropic API
/v1/responses   localhost:38440    /v1/responses →     api.deepseek.com/anthropic
```

## Prerequisites

- macOS (Linux support coming)
- [Homebrew](https://brew.sh) (for auto-installing dependencies)

Everything else (Go, Node, Codex CLI) is installed automatically by `setup.sh` if missing.

## Manual usage

Once set up, start moon-bridge before launching Codex:

```bash
~/moon-bridge/moonbridge --config ~/moon-bridge/config.yml &
codex
```

## Using as a Claude Code skill

This repo is also a [Claude Code](https://claude.ai/code) skill. After cloning:

```bash
cp -r codex-deepseek ~/.claude/skills/
```

Claude will automatically detect and use it when you ask about connecting Codex to DeepSeek.

## Files

| File | Purpose |
|---|---|
| `SKILL.md` | Claude Code skill definition (trigger + instructions) |
| `scripts/setup.sh` | Full one-shot setup |
| `scripts/start.sh` | Daily quick-start (moon-bridge + codex) |

## Troubleshooting

| Problem | Fix |
|---|---|
| `connection refused` | Moon Bridge isn't running — start it first |
| `401` / auth error | Regenerate `config.yml` with a valid API key |
| `codex: command not found` | `npm install -g @openai/codex` |
| Port 38440 in use | `lsof -ti:38440 \| xargs kill` |

## License

MIT
