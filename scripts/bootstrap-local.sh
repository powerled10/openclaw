#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${CRIS_REPO_URL:-https://github.com/powerled10/openclaw.git}"
TARGET_DIR="${CRIS_TARGET_DIR:-$HOME/cris-openclaw}"
LOG_DIR="$HOME/.openclaw/logs"
mkdir -p "$LOG_DIR"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Faltando comando: $1"; exit 1; }; }
need git
need bash
need tar
need openssl

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js não encontrado. Instale Node 20+ e rode novamente."; exit 1
fi
if ! command -v npm >/dev/null 2>&1; then
  echo "npm não encontrado. Instale Node.js completo e rode novamente."; exit 1
fi

if [ ! -d "$TARGET_DIR/.git" ]; then
  git clone "$REPO_URL" "$TARGET_DIR"
else
  git -C "$TARGET_DIR" fetch origin
  git -C "$TARGET_DIR" pull --rebase origin master || true
fi

if ! command -v openclaw >/dev/null 2>&1; then
  npm install -g openclaw
fi

mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/cristina" <<'SH'
#!/usr/bin/env bash
exec "$HOME/cris-openclaw/scripts/start-cristina.sh" "$@"
SH
cat > "$HOME/.local/bin/cristina-update" <<'SH'
#!/usr/bin/env bash
exec "$HOME/cris-openclaw/scripts/cristina-update.sh" "$@"
SH
cat > "$HOME/.local/bin/cristina-sync" <<'SH'
#!/usr/bin/env bash
exec "$HOME/cris-openclaw/scripts/cristina-sync.sh" "$@"
SH
chmod +x "$HOME/.local/bin/cristina" "$HOME/.local/bin/cristina-update" "$HOME/.local/bin/cristina-sync"

grep -q 'HOME/.local/bin' "$HOME/.bashrc" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"

echo "Bootstrap concluído. Abra novo terminal e use: cristina"