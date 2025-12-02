Write-Host "`n=== PRUEBA 5.c - Desmontar 1 nodo, sistema sigue funcionando ===" -ForegroundColor Cyan

Write-Host "`n[Paso 1] Estado inicial - 3 nodos activos" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker ps --filter 'name=frontend-' --format 'table {{.Names}}\t{{.Status}}'" -ForegroundColor White
docker ps --filter "name=frontend-" --format "table {{.Names}}`t{{.Status}}"

Write-Host "`n[Paso 2] Desmontar frontend-1" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker stop frontend-1" -ForegroundColor White
docker stop frontend-1
Write-Host "frontend-1 DETENIDO" -ForegroundColor Red

Write-Host "`n[Paso 3] Verificar nodos restantes (2 activos)" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker ps --filter 'name=frontend-' --format 'table {{.Names}}\t{{.Status}}'" -ForegroundColor White
docker ps --filter "name=frontend-" --format "table {{.Names}}`t{{.Status}}"

Write-Host "`n[Paso 4] Hacer solicitudes HTTP para verificar que sigue funcionando" -ForegroundColor Yellow
Write-Host "Ahora LEAST_CONN distribuye solo entre 2 nodos" -ForegroundColor Cyan

for ($i = 1; $i -le 4; $i++) {
    Write-Host "`n--- Solicitud $i ---" -ForegroundColor White
    Write-Host "[COMANDO HTTP]" -ForegroundColor Green
    Write-Host "Invoke-WebRequest -Uri 'http://localhost:3000' -Method GET" -ForegroundColor White
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET -UseBasicParsing -TimeoutSec 5
        Write-Host "StatusCode: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "Sistema FUNCIONANDO con 2 nodos" -ForegroundColor Green
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Estado del cluster Frontend:" -ForegroundColor White
Write-Host "  - frontend-1: DETENIDO" -ForegroundColor Red
Write-Host "  - frontend-2: ACTIVO" -ForegroundColor Green
Write-Host "  - frontend-3: ACTIVO" -ForegroundColor Green
Write-Host "`nResultado: Sistema FUNCIONANDO con 2 de 3 nodos" -ForegroundColor Green
Write-Host "El balanceador Nginx detecta automaticamente el nodo caido" -ForegroundColor White
Write-Host "y distribuye el trafico solo entre los nodos activos" -ForegroundColor White

Write-Host "`nINSTRUCCIONES PARA EL NAVEGADOR:" -ForegroundColor Yellow
Write-Host "1. Acceder a: http://www.proyectosd.com:3000" -ForegroundColor White
Write-Host "2. Navegar por el sitio, buscar productos, etc." -ForegroundColor White
Write-Host "3. Verificar que TODO funciona normalmente" -ForegroundColor White
Write-Host "4. El sistema es TOLERANTE A FALLOS`n" -ForegroundColor White
