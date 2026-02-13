#!/usr/bin/env bash
set -euo pipefail

ROOT="${CRIS_TARGET_DIR:-$HOME/cris-openclaw}"
ENC_FILE="$ROOT/state/cris-state.enc"
KEY_FILE="${CRIS_STATE_KEY_FILE:-$HOME/.openclaw/.state_key}"
TMP_DIR="${TMPDIR:-/tmp}/cris-restore"

if [ ! -f "$ENC_FILE" ]; then
  echo "Nenhum estado criptografado encontrado em: $ENC_FILE"
  exit 0
fi
if [ ! -f "$KEY_FILE" ]; then
  echo "Chave de estado ausente em $KEY_FILE"
  exit 1
fi

rm -rf "$TMP_DIR" && mkdir -p "$TMP_DIR"
openssl enc -d -aes-256-cbc -pbkdf2 -in "$ENC_FILE" -out "$TMP_DIR/state.tar.gz" -pass file:"$KEY_FILE"
tar -xzf "$TMP_DIR/state.tar.gz" -C "$TMP_DIR"

mkdir -p "$HOME/.openclaw"
cp -a "$TMP_DIR/home-openclaw/." "$HOME/.openclaw/"

echo "Estado restaurado em ~/.openclaw"