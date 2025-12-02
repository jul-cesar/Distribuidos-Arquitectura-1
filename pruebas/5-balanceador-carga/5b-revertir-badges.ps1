Write-Host "`n=== REVERTIR: Eliminar badges de identificacion ===" -ForegroundColor Cyan

Write-Host "`n[Metodo] Reiniciar los contenedores frontend" -ForegroundColor Yellow
Write-Host "Al reiniciar, se recargaran los archivos HTML originales" -ForegroundColor Gray

Write-Host "`n[Ejecutando]" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker restart frontend-1 frontend-2 frontend-3" -ForegroundColor White

docker restart frontend-1 frontend-2 frontend-3

Write-Host "`nEsperando a que los contenedores se reinicien..." -ForegroundColor Gray
Start-Sleep -Seconds 8

Write-Host "`n[Verificando]" -ForegroundColor Yellow
docker ps --filter "name=frontend-" --format "table {{.Names}}`t{{.Status}}"

Write-Host "`n=== BADGES ELIMINADOS ===" -ForegroundColor Green
Write-Host "Los frontends volvieron a su estado original" -ForegroundColor White
Write-Host "Acceder a http://localhost:3000 para verificar`n" -ForegroundColor White
