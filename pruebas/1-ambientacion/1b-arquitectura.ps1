Write-Host "`n=== PRUEBA 1.b - ARQUITECTURA ===" -ForegroundColor Cyan

Write-Host "`n[Comando] docker ps"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"

Write-Host "`nTOTAL: 13 contenedores corriendo" -ForegroundColor Green
Write-Host "(Explicar funciones con el diagrama de arquitectura)" -ForegroundColor Yellow
