---
name: codex-deepseek
description: |
  Connect OpenAI Codex CLI to DeepSeek models (DeepSeek-V4 Pro, etc.) via Moon Bridge.
  Use this skill whenever the user wants to run Codex with DeepSeek, set up Codex+DeepSeek,
  switch Codex to DeepSeek, connect Codex to a DeepSeek API key, or mentions "codex deepseek"
  together. Also trigger when the user asks about running Codex with non-OpenAI models
  or asks how to use their DeepSeek API key with Codex CLI.
---

# Codex + DeepSeek

Connect OpenAI Codex CLI to DeepSeek models using [Moon Bridge](https://github.com/ZhiYi-R/moon-bridge) as a protocol translation layer.

## Problem

Codex CLI v0.134+ dropped support for the Chat Completions API (`wire_api = "chat"`) and now only speaks the OpenAI Responses API (`/v1/responses`). DeepSeek doesn't offer a `/v1/responses` endpoint — it uses an Anthropic-compatible Messages API. Sending Codex requests directly to DeepSeek returns `404 Not Found`.

Moon Bridge solves this by running as a local proxy that translates Responses API calls from Codex into Anthropic-format requests that DeepSeek accepts. Your API key stays on your machine — it's stored only in moon-bridge's config, never sent anywhere else.

## Features

- **One-command setup** — clones moon-bridge, writes config, builds the binary, generates Codex config, and starts the proxy
- **Auto-detects prerequisites** — installs missing Go, Node, or Codex CLI via Homebrew (macOS)
- **Secure API key handling** — prompts with hidden input, stored with `chmod 600` in moon-bridge's config only
- **Idempotent** — safe to re-run; skips steps already done, backs up existing Codex config before overwriting
- **Quick-start script** — `start.sh` launches moon-bridge (if not running) then opens Codex, for daily use
- **Zero cloud dependency** — moon-bridge runs entirely on localhost, no third-party proxy involved

## Quickstart

```bash
# 1. Run the setup (prompts for your DeepSeek API key)
bash ~/.claude/skills/codex-deepseek/scripts/setup.sh

# 2. Launch Codex — moon-bridge starts automatically if needed
bash ~/.claude/skills/codex-deepseek/scripts/start.sh
```

Or start manually:

```bash
~/moon-bridge/moonbridge --config ~/moon-bridge/config.yml &
codex
```

## What setup.sh does

1. Checks/installs Go, Node.js, Codex CLI
2. Clones moon-bridge (or `git pull` if already cloned)
3. Prompts for your DeepSeek API key (input hidden)
4. Writes `~/moon-bridge/config.yml` (Transform mode, port 38440)
5. Builds the `moonbridge` binary
6. Backs up existing `~/.codex/config.toml`, generates a new one via moon-bridge
7. Starts moon-bridge in the background
8. Prints ready-to-use instructions

## How it works

```
Codex CLI                  Moon Bridge                 DeepSeek API
─────────                  ───────────                 ────────────
Responses API ───────────→ Transform mode ───────────→ Anthropic API
/v1/responses   localhost:38440    /v1/responses →     api.deepseek.com/anthropic
```

## Troubleshooting

| Problem | Fix |
|---|---|
| `connection refused` | Moon Bridge isn't running — start it first |
| `401` / auth error | Regenerate `config.yml` with a valid DeepSeek API key |
| `codex: command not found` | `npm install -g @openai/codex` |
| Port 38440 already in use | `lsof -ti:38440 \| xargs kill` |
