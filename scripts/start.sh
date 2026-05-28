#!/usr/bin/env bash
set -euo pipefail

# ── Codex + DeepSeek Quick Start ─────────────────────────────────────────
# Starts Moon Bridge (if not running) and launches Codex.

MOON_DIR="$HOME/moon-bridge"
CONFIG_FILE="$MOON_DIR/config.yml"
PORT="${MOON_BRIDGE_PORT:-38440}"

if [ ! -f "$MOON_DIR/moonbridge" ]; then
    echo "Moon Bridge binary not found. Run setup first:"
    echo "  bash $(dirname "$0")/setup.sh"
    exit 1
fi

if ! lsof -ti:"$PORT" >/dev/null 2>&1; then
    echo "→ Starting Moon Bridge..."
    cd "$MOON_DIR"
    nohup ./moonbridge --config "$CONFIG_FILE" > /tmp/moonbridge.log 2>&1 &
    sleep 2
    echo "✔ Moon Bridge running on port $PORT"
else
    echo "✔ Moon Bridge already running on port $PORT"
fi

exec codex "$@"
