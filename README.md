# Codex + DeepSeek skill for claude users

> One-command setup that builds a local protocol bridge between OpenAI Codex CLI and DeepSeek models. **Stop hand-editing YAML — this script wires it all for you.**

Clone this repo, run `setup.sh`, and you have a working Codex→DeepSeek connection. No Claude required. If you do use [Claude Code](https://claude.ai/code), drop this into `~/.claude/skills/` and Claude will run the setup for you when you ask.

[中文文档](README-zh.md) | [License](LICENSE)

## Inspiration

This project is based on the official [DeepSeek + Codex integration guide](https://github.com/deepseek-ai/awesome-deepseek-agent/blob/main/docs/codex.md) from the DeepSeek team. That guide walks through installing Go, cloning Moon Bridge, writing `config.yml` by hand, generating Codex config via CLI flags, and managing the proxy process — all manually.

This repo wraps every step into **one script** so you don't need to be an engineer to get it working. If the original guide feels like a tech doc, this is the one-click installer.

## The Mindset

This repo demonstrates a general pattern for solving "protocol mismatch" problems in AI tooling:

1. **Identify the gap** — Codex speaks Responses API, DeepSeek speaks Anthropic Messages API. They'll never talk directly.
2. **Find a translation layer** — Moon Bridge sits in the middle, converting requests between the two protocols.
3. **Automate the wiring** — Don't just document the fix; script the entire setup: clone, configure, build, launch.

Apply this same mindset to any two tools that speak different protocols: find the local proxy, automate the config. Don't spend hours hand-editing YAML when a script can do it in seconds.

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
# 1. Clone and run setup (prompts for your DeepSeek API key)
git clone https://github.com/veritasian/codex-deepseek.git
bash codex-deepseek/scripts/setup.sh

# 2. After setup, launch Codex — moon-bridge starts automatically
bash codex-deepseek/scripts/start.sh
```

Get your API key at [platform.deepseek.com/api_keys](https://platform.deepseek.com/api_keys).

## Daily use (after setup)

Once `setup.sh` has built moon-bridge, you don't need this repo anymore. Just start moon-bridge and run Codex:

```bash
# Option A: use the bundled start script
bash codex-deepseek/scripts/start.sh

# Option B: manual
~/moon-bridge/moonbridge --config ~/moon-bridge/config.yml &
codex
```

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

## Bonus: Claude Code skill

This repo includes a `SKILL.md` — if you use [Claude Code](https://claude.ai/code), install it as a skill:

```bash
cp -r codex-deepseek ~/.claude/skills/
```

Claude will then automatically detect when you want to connect Codex to DeepSeek and run the setup for you. The scripts work perfectly fine without Claude — the skill is just a convenience layer on top.

## Files

| File | Purpose |
|---|---|
| `scripts/setup.sh` | Full one-shot setup (clone moon-bridge → config → build) |
| `scripts/start.sh` | Daily quick-start (launches moon-bridge + codex) |
| `SKILL.md` | Claude Code skill definition (optional integration) |
| `README-zh.md` | Chinese translation of this document |

### How to use any bridge with Claude Code

The mindset from this repo applies to all of them:

1. **Install the bridge** — follow its install command
2. **Point Codex at it** — set `base_url` in `~/.codex/config.toml` to the bridge's local address
3. **Ask Claude to configure it** — if you have Claude Code, say "connect Codex to DeepSeek via CCS" and Claude will walk through the setup

Each bridge solves the same core problem (Codex speaks Responses API, your LLM doesn't) — pick the one that matches your comfort level and toolchain.

## Troubleshooting

| Problem | Fix |
|---|---|
| `connection refused` | Moon Bridge isn't running — start it first |
| `401` / auth error | Regenerate `config.yml` with a valid API key |
| `codex: command not found` | `npm install -g @openai/codex` |
| Port 38440 in use | `lsof -ti:38440 \| xargs kill` |

## License

[MIT](LICENSE)
