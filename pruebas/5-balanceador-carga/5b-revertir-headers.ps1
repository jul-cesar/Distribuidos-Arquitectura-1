Write-Host "`n=== REVERTIR: Eliminar headers personalizados ===" -ForegroundColor Cyan

Write-Host "`n[Metodo] Reiniciar los contenedores frontend" -ForegroundColor Yellow
Write-Host "Al reiniciar, se recargara la configuracion original de Nginx" -ForegroundColor Gray

Write-Host "`n[Ejecutando]" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker restart frontend-1 frontend-2 frontend-3" -ForegroundColor White

docker restart frontend-1 frontend-2 frontend-3 | Out-Null

Write-Host "`nEsperando a que los contenedores se reinicien..." -ForegroundColor Gray
Start-Sleep -Seconds 8

Write-Host "`n[Verificando]" -ForegroundColor Yellow
docker ps --filter "name=frontend-" --format "table {{.Names}}`t{{.Status}}"

Write-Host "`n[Probando]" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing
    $servidor = $response.Headers["X-Served-By"]
    
    if ($servidor) {
        Write-Host "ADVERTENCIA: Header X-Served-By todavia presente: $servidor" -ForegroundColor Yellow
    } else {
        Write-Host "Verificacion exitosa: Headers personalizados eliminados" -ForegroundColor Green
    }
} catch {
    Write-Host "Error al verificar: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== CONFIGURACION REVERTIDA ===" -ForegroundColor Green
Write-Host "Los frontends volvieron a su estado original`n" -ForegroundColor White
