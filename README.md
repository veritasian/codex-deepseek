# Codex + DeepSeek — Claude Code Skill

> A [Claude Code](https://claude.ai/code) skill that builds a local protocol bridge between OpenAI Codex CLI and DeepSeek models. **Stop wrestling with config files — let Claude do it.**

This is a **Claude Code skill**. Install it in `~/.claude/skills/` and Claude will automatically detect when you need to connect Codex to DeepSeek, then run the setup for you. If you don't use Claude Code, the scripts still work standalone — but you'll miss the automatic triggering and guided setup.

[中文文档](README-zh.md) | [License](LICENSE)

## The Mindset

This skill embodies a general pattern for solving "protocol mismatch" problems in AI tooling:

1. **Identify the gap** — Codex speaks Responses API, DeepSeek speaks Anthropic Messages API. They'll never talk directly.
2. **Find a translation layer** — Moon Bridge sits in the middle, converting requests between the two protocols.
3. **Automate the wiring** — The skill doesn't just document the fix; it executes the entire setup: clone, configure, build, launch.

You can apply this same mindset to any two tools that speak different protocols: find the local proxy, automate the config. Don't spend hours hand-editing YAML when Claude can do it in seconds.

## Problem

Codex CLI v0.134+ dropped Chat Completions API support and only speaks the OpenAI Responses API (`/v1/responses`). DeepSeek doesn't offer a `/v1/responses` endpoint — it uses an Anthropic-compatible Messages API. Direct requests return `404 Not Found`.

Moon Bridge runs as a local proxy that translates Responses API calls into Anthropic-format requests that DeepSeek accepts. Your API key never leaves your machine.

## Features

- **Claude-powered setup** — describe what you want, Claude runs the skill
- **One command** — clones, configures, builds, and launches everything
- **Auto-installs prerequisites** — Go, Node, Codex CLI via Homebrew (macOS)
- **Secure** — API key prompt with hidden input, stored `chmod 600`
- **Idempotent** — safe to re-run; skips completed steps
- **Zero cloud dependency** — runs entirely on localhost, no third-party proxy

## Quickstart

### With Claude Code

```
You: "Connect Codex to my DeepSeek API key"
Claude: [triggers this skill, runs setup.sh, done]
You: codex
```

### Without Claude Code

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
- [Claude Code](https://claude.ai/code) (for automatic skill triggering)
- [Homebrew](https://brew.sh) (for auto-installing dependencies)

Everything else (Go, Node, Codex CLI) is installed automatically by `setup.sh` if missing.

## Manual usage

Once set up, start moon-bridge before launching Codex:

```bash
~/moon-bridge/moonbridge --config ~/moon-bridge/config.yml &
codex
```

## Install as a Claude Code skill

```bash
git clone https://github.com/veritasian/codex-deepseek.git
cp -r codex-deepseek ~/.claude/skills/
```

Claude will automatically detect this skill when you mention connecting Codex to DeepSeek, running non-OpenAI models with Codex, or hitting protocol errors between AI tools.

## Files

| File | Purpose |
|---|---|
| `SKILL.md` | Claude Code skill definition (triggers + instructions) |
| `scripts/setup.sh` | Full one-shot setup (clone → config → build → launch) |
| `scripts/start.sh` | Daily quick-start (moon-bridge + codex) |
| `README-zh.md` | Chinese translation of this document |

## Troubleshooting

| Problem | Fix |
|---|---|
| `connection refused` | Moon Bridge isn't running — start it first |
| `401` / auth error | Regenerate `config.yml` with a valid API key |
| `codex: command not found` | `npm install -g @openai/codex` |
| Port 38440 in use | `lsof -ti:38440 \| xargs kill` |

## License

[MIT](LICENSE)
