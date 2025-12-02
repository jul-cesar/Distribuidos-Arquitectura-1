Write-Host "`n=== PRUEBA 1.a - MAQUINAS ===" -ForegroundColor Cyan

Write-Host "`nMaquina 1 - Servidor Windows:" -ForegroundColor Yellow
Write-Host "Hostname: $env:COMPUTERNAME"
Write-Host "`n[Comando] docker ps"
docker ps --format "table {{.Names}}\t{{.Status}}"

Write-Host "`nMaquina 2 - Cliente Ubuntu VM" -ForegroundColor Yellow
Write-Host "Funcion: Hacer peticiones al servidor"

Write-Host "`nRESUMEN: 2 maquinas (Servidor Windows + Cliente Ubuntu VM)`n" -ForegroundColor Green
