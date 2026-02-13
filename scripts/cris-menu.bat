@echo off
setlocal

set "PS_SCRIPT=%TEMP%\cris-installer.ps1"

echo Baixando Cris Installer...
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr 'https://raw.githubusercontent.com/powerled10/openclaw/master/scripts/cris-installer.ps1' -OutFile '%PS_SCRIPT%'"
if errorlevel 1 (
  echo Falha ao baixar o instalador.
  pause
  exit /b 1
)

echo Iniciando menu da Cris...
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"

endlocal
