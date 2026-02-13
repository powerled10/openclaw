param()

$ErrorActionPreference = "Stop"

function Write-Title($t) {
  Write-Host "`n=== $t ===" -ForegroundColor Cyan
}

function Test-Cmd($name) {
  return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

function Ensure-Node {
  if (-not (Test-Cmd "node") -or -not (Test-Cmd "npm")) {
    Write-Host "Node.js/npm não encontrados. Instale Node.js 20+ e rode novamente." -ForegroundColor Yellow
    throw "Node.js ausente"
  }
}

function Ensure-Git {
  if (-not (Test-Cmd "git")) {
    Write-Host "Git não encontrado. Instale Git for Windows e rode novamente." -ForegroundColor Yellow
    throw "Git ausente"
  }
}

function Ensure-OpenSSL {
  if (-not (Test-Cmd "openssl")) {
    Write-Host "OpenSSL não encontrado no PATH." -ForegroundColor Yellow
    Write-Host "Dica: instalar Git for Windows completo normalmente inclui openssl no Git Bash." -ForegroundColor DarkYellow
    throw "OpenSSL ausente"
  }
}

function Install-CrisBase {
  Write-Title "Instalação base da Cris/OpenClaw"

  Ensure-Git
  Ensure-Node

  $repoUrl = Read-Host "URL do repositório [default: https://github.com/powerled10/openclaw.git]"
  if ([string]::IsNullOrWhiteSpace($repoUrl)) { $repoUrl = "https://github.com/powerled10/openclaw.git" }

  $targetDir = Read-Host "Pasta local [default: $env:USERPROFILE\cris-openclaw]"
  if ([string]::IsNullOrWhiteSpace($targetDir)) { $targetDir = "$env:USERPROFILE\cris-openclaw" }

  if (-not (Test-Path "$targetDir\.git")) {
    git clone $repoUrl $targetDir
  } else {
    git -C $targetDir fetch origin
    git -C $targetDir pull --rebase origin master
  }

  if (-not (Test-Cmd "openclaw")) {
    npm install -g openclaw
  }

  $scriptsDir = Join-Path $targetDir "scripts"
  if (-not (Test-Path $scriptsDir)) { throw "Pasta scripts não encontrada em $targetDir" }

  $binDir = "$env:USERPROFILE\bin"
  New-Item -ItemType Directory -Force -Path $binDir | Out-Null

  $crisCmd = @"
@echo off
bash "$targetDir/scripts/start-cristina.sh" %*
"@
  $crisUpdateCmd = @"
@echo off
bash "$targetDir/scripts/cristina-update.sh" %*
"@
  $crisSyncCmd = @"
@echo off
bash "$targetDir/scripts/cristina-sync.sh" %*
"@

  Set-Content -Path (Join-Path $binDir "cristina.cmd") -Value $crisCmd -Encoding ASCII
  Set-Content -Path (Join-Path $binDir "cristina-update.cmd") -Value $crisUpdateCmd -Encoding ASCII
  Set-Content -Path (Join-Path $binDir "cristina-sync.cmd") -Value $crisSyncCmd -Encoding ASCII

  if ($env:Path -notlike "*$binDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$env:Path;$binDir", "User")
    Write-Host "Adicionei $binDir ao PATH do usuário. Abra novo terminal após o script." -ForegroundColor Green
  }

  Write-Host "Instalação base concluída em: $targetDir" -ForegroundColor Green
}

function Configure-StateKey {
  Write-Title "Configurar chave de estado (.state_key)"
  Ensure-OpenSSL

  $openclawDir = "$env:USERPROFILE\.openclaw"
  New-Item -ItemType Directory -Force -Path $openclawDir | Out-Null

  $keyPath = Join-Path $openclawDir ".state_key"
  $key = Read-Host "Cole a chave de estado (uma linha)"
  if ([string]::IsNullOrWhiteSpace($key)) { throw "Chave vazia" }

  Set-Content -Path $keyPath -Value $key -NoNewline -Encoding ASCII
  Write-Host "Chave salva em $keyPath" -ForegroundColor Green
}

function Ask-Step3 {
  Write-Title "Passo 3 (opcional): sincronizar e subir"
  $opt = Read-Host "Executar agora? (S/N)"
  if ($opt -match '^(s|S|y|Y)$') {
    if (-not (Test-Cmd "cristina-sync")) {
      Write-Host "Comando cristina-sync não encontrado no terminal atual. Abra novo terminal e rode novamente." -ForegroundColor Yellow
      return
    }
    cristina-sync
    cristina
  }
}

function Show-OtherSystemInstructions {
  Write-Title "Instalar em outro sistema"
  Write-Host "Linux/macOS/Git Bash:"
  Write-Host "curl -fsSL https://raw.githubusercontent.com/powerled10/openclaw/master/scripts/bootstrap-local.sh | bash" -ForegroundColor Yellow
  Write-Host "Depois: configurar ~/.openclaw/.state_key, executar cristina-sync e cristina." -ForegroundColor Yellow
}

function Sync-Only {
  Write-Title "Sincronizar Cris"
  if (-not (Test-Cmd "cristina-sync")) {
    Write-Host "Comando cristina-sync não encontrado. Abra novo terminal ou rode instalação base." -ForegroundColor Yellow
    return
  }
  cristina-sync
  Write-Host "Sync concluído." -ForegroundColor Green
}

function Maintenance {
  Write-Title "Manutenção da Cris"
  if (-not (Test-Cmd "cristina-update")) {
    Write-Host "Comando cristina-update não encontrado. Abra novo terminal ou rode instalação base." -ForegroundColor Yellow
    return
  }
  cristina-update
}

function Install-NotebookFlow {
  Install-CrisBase
  Configure-StateKey
  Ask-Step3
}

while ($true) {
  Write-Title "Menu Cris Installer (PowerShell)"
  Write-Host "1) Instalar OpenClaw + Cris neste notebook (passo 1 + passo 2 + opcional passo 3)"
  Write-Host "2) Preparar instalação da Cris em outro sistema"
  Write-Host "3) Só sincronizar a Cris"
  Write-Host "4) Manutenção da Cris"
  Write-Host "5) Sair"

  $choice = Read-Host "Escolha uma opção (1-5)"

  switch ($choice) {
    "1" { Install-NotebookFlow }
    "2" { Show-OtherSystemInstructions }
    "3" { Sync-Only }
    "4" { Maintenance }
    "5" { break }
    default { Write-Host "Opção inválida." -ForegroundColor Yellow }
  }
}
