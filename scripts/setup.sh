#!/usr/bin/env bash
set -euo pipefail

# ── Codex + DeepSeek Setup ───────────────────────────────────────────────
# Connects OpenAI Codex CLI to DeepSeek models via Moon Bridge.
# Repo: https://github.com/ZhiYi-R/moon-bridge

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { printf "${CYAN}→${NC} %s\n" "$*"; }
ok()   { printf "${GREEN}✔${NC} %s\n" "$*"; }
warn() { printf "${YELLOW}⚠${NC} %s\n" "$*"; }
err()  { printf "${RED}✖${NC} %s\n" "$*"; exit 1; }

MOON_DIR="$HOME/moon-bridge"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CONFIG_FILE="$MOON_DIR/config.yml"
PORT="${MOON_BRIDGE_PORT:-38440}"

# ── 1. Prerequisites ─────────────────────────────────────────────────────

log "Checking prerequisites..."

command -v go    >/dev/null 2>&1 || {
    warn "Go not found — installing via Homebrew..."
    brew install go || err "Failed to install Go. Install manually: https://go.dev/dl/"
}
ok "Go $(go version | awk '{print $3}')"

command -v node  >/dev/null 2>&1 || {
    warn "Node.js not found — installing via Homebrew..."
    brew install node || err "Failed to install Node.js."
}
ok "Node $(node --version)"

command -v codex >/dev/null 2>&1 || {
    warn "Codex CLI not found — installing via npm..."
    npm install -g @openai/codex || err "Failed to install Codex CLI."
}
ok "Codex $(codex --version 2>&1 | head -1)"

# ── 2. Clone / update Moon Bridge ────────────────────────────────────────

if [ -d "$MOON_DIR" ]; then
    log "Moon Bridge already cloned at $MOON_DIR"
    git -C "$MOON_DIR" pull --ff-only 2>/dev/null || warn "Could not pull latest moon-bridge (continuing with existing)"
else
    log "Cloning Moon Bridge..."
    git clone https://github.com/ZhiYi-R/moon-bridge.git "$MOON_DIR"
    ok "Moon Bridge cloned"
fi

# ── 3. API Key ───────────────────────────────────────────────────────────

if [ -f "$CONFIG_FILE" ] && grep -q 'api_key: "sk-' "$CONFIG_FILE" 2>/dev/null; then
    EXISTING_KEY=$(grep 'api_key:' "$CONFIG_FILE" | head -1 | sed 's/.*"\(sk-[^"]*\)".*/\1/')
    log "Found existing API key in config: ${EXISTING_KEY:0:12}..."
    printf "    Reuse existing key? [Y/n] "
    read -r REUSE
    if [ "${REUSE:-y}" = "y" ] || [ "${REUSE:-y}" = "Y" ] || [ -z "$REUSE" ]; then
        API_KEY="$EXISTING_KEY"
    else
        printf "    Enter DeepSeek API key: "
        read -rs API_KEY
        echo
    fi
else
    printf "    Enter your DeepSeek API key (from https://platform.deepseek.com/api_keys): "
    read -rs API_KEY
    echo
fi

[ -z "$API_KEY" ] && err "API key is required."
ok "API key: ${API_KEY:0:12}..."

# ── 4. Generate moon-bridge config.yml ───────────────────────────────────

log "Writing moon-bridge config..."

mkdir -p "$MOON_DIR/data"

cat > "$CONFIG_FILE" << YAML
mode: "Transform"

log:
  level: "info"
  format: "text"

server:
  addr: "127.0.0.1:${PORT}"

persistence:
  active_provider: db_sqlite

extensions:
  deepseek_v4:
    config:
      reinforce_instructions: true
      reinforce_prompt: "[System Reminder]: Please pay close attention to the system instructions, AGENTS.md files, and any other context provided. Follow them carefully and completely in your response.\\n[User]:"

cache:
  mode: "explicit"
  ttl: "5m"
  prompt_caching: true

defaults:
  model: "moonbridge"
  max_tokens: 65536

models:
  deepseek-v4-pro:
    context_window: 1000000
    max_output_tokens: 384000
    display_name: "DeepSeek V4 Pro"
    description: "DeepSeek V4 with selectable high/xhigh reasoning effort."
    default_reasoning_level: "high"
    supported_reasoning_levels:
      - effort: "high"
        description: "High reasoning effort"
      - effort: "xhigh"
        description: "Extra high reasoning effort (maps to DeepSeek max)"
    supports_reasoning_summaries: true
    default_reasoning_summary: "auto"
    extensions:
      deepseek_v4:
        enabled: true

providers:
  deepseek:
    base_url: "https://api.deepseek.com/anthropic"
    api_key: "${API_KEY}"
    version: "2023-06-01"
    user_agent: "moonbridge/1.0"
    offers:
      - model: deepseek-v4-pro
        pricing:
          input_price: 2
          output_price: 8
          cache_write_price: 1
          cache_read_price: 0.2

routes:
  moonbridge:
    model: deepseek-v4-pro
    provider: deepseek
YAML

chmod 600 "$CONFIG_FILE"
ok "Config written to $CONFIG_FILE"

# ── 5. Build moonbridge binary ───────────────────────────────────────────

log "Building moonbridge binary..."
cd "$MOON_DIR"
go build -o moonbridge ./cmd/moonbridge 2>&1 || err "Build failed. Check Go setup."
ok "Binary built: $MOON_DIR/moonbridge"

# ── 6. Generate Codex config ─────────────────────────────────────────────

log "Generating Codex config..."

mkdir -p "$CODEX_HOME"

# Backup existing config if it exists
if [ -f "$CODEX_HOME/config.toml" ]; then
    cp "$CODEX_HOME/config.toml" "$CODEX_HOME/config.toml.bak"
    ok "Backed up existing config to config.toml.bak"
fi

MODEL=$(./moonbridge --config "$CONFIG_FILE" --print-codex-model 2>/dev/null)

./moonbridge \
    --config "$CONFIG_FILE" \
    --print-codex-config "$MODEL" \
    --codex-base-url "http://127.0.0.1:${PORT}/v1" \
    --codex-home "$CODEX_HOME" \
    > "$CODEX_HOME/config.toml" 2>/dev/null

# Add back common settings
cat >> "$CODEX_HOME/config.toml" << TOML

[projects."/Users/$(whoami)"]
trust_level = "trusted"

[projects."/"]
trust_level = "trusted"
TOML

ok "Codex config written to $CODEX_HOME/config.toml"
ok "Model catalog written to $CODEX_HOME/models_catalog.json"

# ── 7. Start Moon Bridge ─────────────────────────────────────────────────

if lsof -ti:"$PORT" >/dev/null 2>&1; then
    warn "Port $PORT is already in use — Moon Bridge may already be running"
else
    log "Starting Moon Bridge on port $PORT..."
    cd "$MOON_DIR"
    nohup ./moonbridge --config "$CONFIG_FILE" > /tmp/moonbridge.log 2>&1 &
    sleep 2

    if lsof -ti:"$PORT" >/dev/null 2>&1; then
        ok "Moon Bridge running at http://127.0.0.1:${PORT}"
        ok "PID: $(lsof -ti:"$PORT")"
    else
        warn "Moon Bridge may not have started. Check /tmp/moonbridge.log"
    fi
fi

# ── 8. Done ──────────────────────────────────────────────────────────────

echo ""
printf "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
printf "${GREEN}  Codex + DeepSeek is ready!${NC}\n"
printf "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
echo ""
echo "  To use:"
echo "    1. Ensure Moon Bridge is running:"
echo "       ~/moon-bridge/moonbridge --config ~/moon-bridge/config.yml &"
echo ""
echo "    2. Launch Codex:"
echo "       codex"
echo ""
echo "  Quick start (from this skill):"
echo "       bash $(dirname "$0")/start.sh"
echo ""
