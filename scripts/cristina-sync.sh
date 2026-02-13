#!/usr/bin/env bash
set -euo pipefail

WORKDIR="/sec/root/.openclaw/workspace"
LOG_DIR="$HOME/.openclaw/logs"
mkdir -p "$LOG_DIR"

DO_PUSH="false"
if [ "${1:-}" = "--push" ]; then DO_PUSH="true"; fi

cd "$WORKDIR"

git fetch origin >> "$LOG_DIR/sync.log" 2>&1 || true
git pull --rebase origin master >> "$LOG_DIR/sync.log" 2>&1 || true

# aplica estado criptografado se houver
if [ -f "$WORKDIR/state/cris-state.enc" ]; then
  "$WORKDIR/scripts/cristina-state-apply.sh" >> "$LOG_DIR/sync.log" 2>&1 || true
fi

if [ "$DO_PUSH" = "true" ]; then
  "$WORKDIR/scripts/cristina-state-pack.sh" >> "$LOG_DIR/sync.log" 2>&1 || true
  git add state/cris-state.enc 2>/dev/null || true
  if ! git diff --cached --quiet; then
    git commit -m "Update encrypted Cristina state snapshot" >> "$LOG_DIR/sync.log" 2>&1 || true
  fi
  git push origin master >> "$LOG_DIR/sync.log" 2>&1 || true
fi

echo "sync ok"