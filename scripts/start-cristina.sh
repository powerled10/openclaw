#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="${HOME}/.openclaw/logs"
mkdir -p "$LOG_DIR"

# Sobe o gateway se não estiver rodando
if ! openclaw gateway status >/dev/null 2>&1; then
  openclaw gateway start >> "$LOG_DIR/startup.log" 2>&1 || true
fi

# Mostra estado resumido
openclaw status --deep
