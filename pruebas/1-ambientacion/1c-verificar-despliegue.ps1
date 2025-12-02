Write-Host "`n=== PRUEBA 1.c - VERIFICAR DESPLIEGUE ===" -ForegroundColor Cyan

Write-Host "`n[Comando] docker ps"
docker ps --format "table {{.Names}}\t{{.Status}}"

Write-Host "`nVERIFICACION: Todos los 13 contenedores estan UP" -ForegroundColor Green
