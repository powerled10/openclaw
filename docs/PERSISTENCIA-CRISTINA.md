# Persistência da Cristina (OpenClaw)

## O que foi configurado

1. **Auto-start no boot da VPS**
   - Cron: `@reboot openclaw gateway start`

2. **Backup automático**
   - Cron: a cada 6 horas (`15 */6 * * *`)
   - Script: `/sec/root/.openclaw/workspace/scripts/backup-openclaw.sh`
   - Saída: `~/.openclaw/backups/openclaw-backup-<timestamp>.tar.gz`
   - Retenção: 14 dias

3. **Comando padrão para subir/validar a Cristina**
   - Comando: `cristina`
   - Script alvo: `/sec/root/.openclaw/workspace/scripts/start-cristina.sh`

## Uso rápido via SSH

```bash
ssh root@SEU_HOST "cristina"
```

## Onde ficam os dados essenciais

- `~/.openclaw/openclaw.json`
- `~/.openclaw/credentials/`
- `~/.openclaw/agents/`
- `/sec/root/.openclaw/workspace/`

## Verificação

```bash
crontab -l
openclaw status --deep
ls -lah ~/.openclaw/backups | tail
```
