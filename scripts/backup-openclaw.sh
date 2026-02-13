#!/usr/bin/env bash
set -euo pipefail

TS="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
BACKUP_DIR="${HOME}/.openclaw/backups"
LOG_DIR="${HOME}/.openclaw/logs"
mkdir -p "$BACKUP_DIR" "$LOG_DIR"

OUT="$BACKUP_DIR/openclaw-backup-${TS}.tar.gz"

# Backup dos dados essenciais do OpenClaw + workspace
# (usa paths absolutos para evitar depender do cwd)
tar -czf "$OUT" \
  "$HOME/.openclaw/openclaw.json" \
  "$HOME/.openclaw/credentials" \
  "$HOME/.openclaw/agents" \
  "/sec/root/.openclaw/workspace" \
  >> "$LOG_DIR/backup.log" 2>&1

# Retenção: mantém 14 dias
find "$BACKUP_DIR" -type f -name 'openclaw-backup-*.tar.gz' -mtime +14 -delete

echo "[$(date -u +%F' '%T'Z')] backup ok: $OUT" >> "$LOG_DIR/backup.log"
