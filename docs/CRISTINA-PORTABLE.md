# Cristina portátil (VPS + notebook + qualquer lugar)

## 1) Instalação em qualquer máquina (curl | bash)

> Requisitos: Git + Node.js 20+ + npm + OpenSSL + tar + bash

```bash
curl -fsSL https://raw.githubusercontent.com/powerled10/openclaw/master/scripts/bootstrap-local.sh | bash
```

Depois abra novo terminal e rode:

```bash
cristina-sync
cristina
```

## 2) Chave de sincronismo de estado (criptografado)

Crie em cada máquina (mesmo conteúdo):

```bash
mkdir -p ~/.openclaw
cat > ~/.openclaw/.state_key <<'EOF'
COLE_A_CHAVE_AQUI
EOF
chmod 600 ~/.openclaw/.state_key
```

Sem essa chave, só os arquivos do git sincronizam; com ela, o estado do OpenClaw (config/credenciais/sessões) sincroniza criptografado.

## 3) Fluxo recomendado

### VPS (origem principal)
- Já está configurado para rodar a cada 30 min:
  - `cristina-sync --push` (pack + push do estado criptografado)

### Notebook / máquina temporária
```bash
cristina-sync
cristina
```

## 4) Operação segura (ativo-passivo para Telegram)

Não rode VPS e notebook ao mesmo tempo com o mesmo bot Telegram.

- modo normal: VPS ativa
- failover: parar VPS, subir notebook
- retorno: parar notebook, subir VPS

## 5) Comandos úteis

```bash
cristina              # sobe/valida a Cris
cristina-update       # manutenção completa
cristina-sync         # sync git + restore estado criptografado
cristina-sync --push  # (origem) gera snapshot criptografado e publica no git
```
