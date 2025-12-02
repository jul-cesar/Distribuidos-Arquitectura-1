Write-Host "`n=== PRUEBA 3.b - Cerrar puerto 3000 y probar ===" -ForegroundColor Cyan

Write-Host "`nNOTA: En Docker, 'cerrar puerto' = detener el contenedor frontend-lb" -ForegroundColor Yellow
Write-Host "Esto simula bloquear el acceso HTTP desde la red externa" -ForegroundColor Yellow

Write-Host "`n[Paso 1] Verificar que la pagina funciona ANTES de cerrar puerto" -ForegroundColor Cyan
Write-Host "[Comando] Invoke-WebRequest http://localhost:3000" -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "ANTES: Pagina accesible - StatusCode $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "ANTES: Pagina NO accesible" -ForegroundColor Red
}

Write-Host "`n[Paso 2] Cerrar puerto 3000 (detener frontend-lb)" -ForegroundColor Cyan
Write-Host "[Comando] docker stop frontend-lb" -ForegroundColor Yellow
docker stop frontend-lb

Write-Host "`n[Paso 3] Intentar acceder desde navegador/curl" -ForegroundColor Cyan
Write-Host "[Comando] Invoke-WebRequest http://localhost:3000" -ForegroundColor Gray
Start-Sleep -Seconds 2
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "DESPUES: Pagina accesible - StatusCode $($response.StatusCode)" -ForegroundColor Red
    Write-Host "ERROR: El puerto deberia estar cerrado!" -ForegroundColor Red
} catch {
    Write-Host "DESPUES: Pagina NO accesible (puerto cerrado correctamente)" -ForegroundColor Green
    Write-Host "Error esperado: $($_.Exception.Message)" -ForegroundColor Gray
}

Write-Host "`nRESULTADO:" -ForegroundColor Yellow
Write-Host "- Puerto 3000 CERRADO (frontend-lb detenido)" -ForegroundColor White
Write-Host "- Navegador NO puede cargar la pagina" -ForegroundColor White
Write-Host "- Cliente externo bloqueado" -ForegroundColor White

Write-Host "`nPRUEBA DESDE NAVEGADOR:" -ForegroundColor Cyan
Write-Host "Abrir: http://localhost:3000" -ForegroundColor White
Write-Host "Resultado esperado: 'No se puede acceder a este sitio web'" -ForegroundColor Yellow

Write-Host "`nNOTA: Ejecutar script 3c para REABRIR el puerto`n" -ForegroundColor Red
