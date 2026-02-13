#!/usr/bin/env bash
set -euo pipefail

ROOT="/sec/root/.openclaw/workspace"
OUT_DIR="$ROOT/state"
TMP_DIR="${TMPDIR:-/tmp}/cris-state"
KEY_FILE="${CRIS_STATE_KEY_FILE:-$HOME/.openclaw/.state_key}"
mkdir -p "$OUT_DIR" "$TMP_DIR"

if [ ! -f "$KEY_FILE" ]; then
  echo "Chave de estado não encontrada em $KEY_FILE"
  echo "Crie com: openssl rand -base64 48 > $KEY_FILE && chmod 600 $KEY_FILE"
  exit 1
fi

rm -rf "$TMP_DIR" && mkdir -p "$TMP_DIR"
mkdir -p "$TMP_DIR/home-openclaw"
cp -a "$HOME/.openclaw/openclaw.json" "$TMP_DIR/home-openclaw/" 2>/dev/null || true
cp -a "$HOME/.openclaw/credentials" "$TMP_DIR/home-openclaw/" 2>/dev/null || true
cp -a "$HOME/.openclaw/agents" "$TMP_DIR/home-openclaw/" 2>/dev/null || true

TAR_FILE="$OUT_DIR/cris-state.tar.gz"
ENC_FILE="$OUT_DIR/cris-state.enc"

tar -czf "$TAR_FILE" -C "$TMP_DIR" .
openssl enc -aes-256-cbc -pbkdf2 -salt -in "$TAR_FILE" -out "$ENC_FILE" -pass file:"$KEY_FILE"
rm -f "$TAR_FILE"

echo "$ENC_FILE"