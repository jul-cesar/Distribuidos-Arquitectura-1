Write-Host "`n=== PRUEBA 2.a - DNS desde servidor (localhost) ===" -ForegroundColor Cyan

Write-Host "`n[Comando] nslookup www.proyectosd.com 127.0.0.1"
Write-Host "Ejecutando desde la maquina donde esta el DNS..." -ForegroundColor Yellow

$result = nslookup www.proyectosd.com 127.0.0.1 2>&1 | Out-String

Write-Host $result

if ($result -match "192\.168\.1\.66|Address.*192\.168") {
    Write-Host "EXITO: DNS retorna la IP del servidor (192.168.1.66)" -ForegroundColor Green
} else {
    Write-Host "Verificar: Deberia retornar IP 192.168.1.66 (donde esta el firewall/load balancers)" -ForegroundColor Yellow
}

Write-Host "`nEXPLICACION:" -ForegroundColor Cyan
Write-Host "- El DNS esta en contenedor dns-server (puerto 53)" -ForegroundColor White
Write-Host "- Resuelve www.proyectosd.com a la IP del servidor Windows" -ForegroundColor White
Write-Host "- El firewall/LB estan en la misma maquina (192.168.1.66)`n" -ForegroundColor White
