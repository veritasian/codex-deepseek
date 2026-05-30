# Codex + DeepSeek — One-Script Bridge

> You want Codex CLI but don't want to pay OpenAI. DeepSeek is cheaper and faster — but the two speak completely different protocols. This repo gives you a single script that builds the bridge, writes the config, and launches everything. CLI power, DeepSeek prices, zero manual setup.

[![Stars](https://img.shields.io/github/stars/veritasian/codex-deepseek)](https://github.com/veritasian/codex-deepseek/stargazers)
[![License](https://img.shields.io/github/license/veritasian/codex-deepseek)](LICENSE)

[中文说明](README-zh.md)

## Pain Point

You want to use Codex CLI — it's fast, terminal-native, and free with OAuth. But it only connects to OpenAI models. DeepSeek V4 offers comparable quality at a fraction of OpenAI's cost. Problem: Codex speaks **Responses API**, DeepSeek speaks **Anthropic Messages API**. They literally can't communicate. You get `404 Not Found`.

The official DeepSeek guide walks you through the fix manually — install Go, clone Moon Bridge, hand-edit `config.yml`, run CLI flags, manage a background proxy. Works, but takes 20+ minutes of YAML and frustration.

## Solution

**One script, end to end.** Clone this repo, run `setup.sh`, and you have a working Codex→DeepSeek connection. The script handles every step: it checks prerequisites (Go, Node, Codex CLI), clones Moon Bridge, writes the config with your API key, builds the binary, generates your `~/.codex/config.toml`, and starts the proxy in the background.

## Quickstart

```bash
git clone https://github.com/veritasian/codex-deepseek.git
bash codex-deepseek/scripts/setup.sh     # prompts for your DeepSeek API key
bash codex-deepseek/scripts/start.sh     # launches moon-bridge + codex
```

**Get your API key:** [platform.deepseek.com/api_keys](https://platform.deepseek.com/api_keys)

## How It Works

```
Codex CLI ──Responses API──→ Moon Bridge ──Anthropic API──→ DeepSeek
          localhost:38440    (local proxy)     api.deepseek.com
```

| Step | What the script does |
|---|---|
| 1. Prerequisites | Checks Go, Node, Codex CLI. Installs missing ones via Homebrew. |
| 2. Moon Bridge | Clones from GitHub (or `git pull` if already cloned) |
| 3. Config | Writes `~/moon-bridge/config.yml` with your API key (`chmod 600`) |
| 4. Build | `go build` the moonbridge binary |
| 5. Codex | Backs up existing `~/.codex/config.toml`, generates a new one pointing to the bridge |
| 6. Launch | Starts moonbridge in background on port 38440, ready for Codex |

## Daily Use

**One-click auto:**
```bash
bash codex-deepseek/scripts/start.sh
```

**Manual:**
```bash
~/moon-bridge/moonbridge --config ~/moon-bridge/config.yml &
codex
```

**Login item (starts on boot):**
System Settings → General → Login Items → `+` → `~/moon-bridge/moonbridge` — add argument: `--config ~/moon-bridge/config.yml`

## Bonus: Claude Code Skill

This repo includes a `SKILL.md`. Install it and Claude handles the entire setup with natural language:

```bash
cp -r codex-deepseek ~/.claude/skills/
```
```
> connect Codex to my DeepSeek API key
```

## Files

| File | Purpose |
|---|---|
| `scripts/setup.sh` | Full setup: clone → config → build → launch |
| `scripts/start.sh` | Quick launcher: starts moon-bridge if needed, opens Codex |
| `SKILL.md` | Claude Code skill for automatic triggering |

## Inspiration

This project is based on the official [DeepSeek + Codex integration guide](https://github.com/deepseek-ai/awesome-deepseek-agent/blob/main/docs/codex.md). That guide walks through the full manual setup — install Go, clone Moon Bridge, write `config.yml` by hand, generate Codex config via CLI, manage the proxy process. This repo wraps the same steps into one script.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `connection refused` | Moon Bridge isn't running — start it first |
| `401 Unauthorized` | Wrong API key — check `~/moon-bridge/config.yml` |
| Port 38440 already in use | `lsof -ti:38440 \| xargs kill` |
| `codex: command not found` | `npm install -g @openai/codex` |

## License

[MIT](LICENSE)
