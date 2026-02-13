#!/usr/bin/env bash
set -euo pipefail

WORKDIR="/sec/root/.openclaw/workspace"
LOG_DIR="${HOME}/.openclaw/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/cristina-update.log"

log() {
  echo "[$(date -u +%F' '%T'Z')] $*" | tee -a "$LOG_FILE"
}

log "Iniciando manutenção da Cristina"

# 1) Garantir gateway ativo
if ! openclaw gateway status >/dev/null 2>&1; then
  log "Gateway parado; iniciando..."
  openclaw gateway start >> "$LOG_FILE" 2>&1 || true
fi

# 2) Sincronizar workspace com GitHub
log "Sincronizando git (fetch + pull --rebase)"
cd "$WORKDIR"
git fetch origin >> "$LOG_FILE" 2>&1 || true
git pull --rebase origin master >> "$LOG_FILE" 2>&1 || true

# 3) Checagens rápidas de saúde
log "Executando openclaw update status"
openclaw update status | tee -a "$LOG_FILE" || true

log "Executando openclaw security audit"
openclaw security audit | tee -a "$LOG_FILE" || true

log "Executando openclaw status --deep"
openclaw status --deep | tee -a "$LOG_FILE" || true

log "Manutenção concluída"
