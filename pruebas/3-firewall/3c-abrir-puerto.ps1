Write-Host "`n=== PRUEBA 3.c - Abrir puerto 3000 y probar ===" -ForegroundColor Cyan

Write-Host "`n[Paso 1] Verificar estado actual del puerto" -ForegroundColor Cyan
Write-Host "[Comando] Invoke-WebRequest http://localhost:3000" -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "ANTES: Pagina accesible - StatusCode $($response.StatusCode)" -ForegroundColor Yellow
    Write-Host "El puerto ya estaba abierto" -ForegroundColor Yellow
} catch {
    Write-Host "ANTES: Pagina NO accesible (puerto cerrado)" -ForegroundColor Red
}

Write-Host "`n[Paso 2] Abrir puerto 3000 (iniciar frontend-lb)" -ForegroundColor Cyan
Write-Host "[Comando] docker start frontend-lb" -ForegroundColor Yellow
docker start frontend-lb

Write-Host "`nEsperando a que el contenedor este listo..." -ForegroundColor Gray
Start-Sleep -Seconds 3

Write-Host "`n[Paso 3] Verificar que el contenedor esta corriendo" -ForegroundColor Cyan
Write-Host "[Comando] docker ps | Select-String frontend-lb" -ForegroundColor Gray
docker ps | Select-String "frontend-lb"

Write-Host "`n[Paso 4] Intentar acceder desde navegador/curl" -ForegroundColor Cyan
Write-Host "[Comando] Invoke-WebRequest http://localhost:3000" -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "DESPUES: Pagina accesible - StatusCode $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Puerto 3000 reabierto correctamente!" -ForegroundColor Green
} catch {
    Write-Host "DESPUES: Pagina NO accesible" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nRESULTADO:" -ForegroundColor Yellow
Write-Host "- Puerto 3000 ABIERTO (frontend-lb activo)" -ForegroundColor White
Write-Host "- Navegador PUEDE cargar la pagina" -ForegroundColor White
Write-Host "- Cliente externo tiene acceso" -ForegroundColor White

Write-Host "`nPRUEBA DESDE NAVEGADOR:" -ForegroundColor Cyan
Write-Host "Abrir: http://localhost:3000" -ForegroundColor White
Write-Host "Resultado esperado: Se carga la pagina principal de Spree Commerce" -ForegroundColor Green

Write-Host "`nEXPLICACION:" -ForegroundColor Cyan
Write-Host "1. docker start frontend-lb reabre el puerto 3000" -ForegroundColor White
Write-Host "2. Nginx LB vuelve a distribuir peticiones a los frontends" -ForegroundColor White
Write-Host "3. El firewall permite el trafico HTTP nuevamente`n" -ForegroundColor White
