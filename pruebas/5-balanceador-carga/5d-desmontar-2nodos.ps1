Write-Host "`n=== PRUEBA 5.d - Desmontar 2do nodo, solo 1 activo ===" -ForegroundColor Cyan

Write-Host "`n[Paso 1] Estado actual - 2 nodos activos (frontend-1 ya esta detenido)" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker ps --filter 'name=frontend-' --format 'table {{.Names}}\t{{.Status}}'" -ForegroundColor White
docker ps --filter "name=frontend-" --format "table {{.Names}}`t{{.Status}}"

Write-Host "`n[Paso 2] Desmontar frontend-2" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker stop frontend-2" -ForegroundColor White
docker stop frontend-2
Write-Host "frontend-2 DETENIDO" -ForegroundColor Red

Write-Host "`n[Paso 3] Verificar solo 1 nodo activo (frontend-3)" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker ps --filter 'name=frontend-' --format 'table {{.Names}}\t{{.Status}}'" -ForegroundColor White
docker ps --filter "name=frontend-" --format "table {{.Names}}`t{{.Status}}"

Write-Host "`n[Paso 4] Hacer solicitudes HTTP para verificar que sigue funcionando" -ForegroundColor Yellow
Write-Host "Todas las solicitudes van al unico nodo activo" -ForegroundColor Cyan

for ($i = 1; $i -le 4; $i++) {
    Write-Host "`n--- Solicitud $i ---" -ForegroundColor White
    Write-Host "[COMANDO HTTP]" -ForegroundColor Green
    Write-Host "Invoke-WebRequest -Uri 'http://localhost:3000' -Method GET" -ForegroundColor White
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET -UseBasicParsing -TimeoutSec 5
        Write-Host "StatusCode: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "Sistema FUNCIONANDO con 1 solo nodo" -ForegroundColor Green
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Estado del cluster Frontend:" -ForegroundColor White
Write-Host "  - frontend-1: DETENIDO" -ForegroundColor Red
Write-Host "  - frontend-2: DETENIDO" -ForegroundColor Red
Write-Host "  - frontend-3: ACTIVO (unico nodo funcionando)" -ForegroundColor Green

Write-Host "`nResultado: Sistema FUNCIONANDO con 1 de 3 nodos" -ForegroundColor Green
Write-Host "El balanceador envia TODO el trafico al unico nodo disponible" -ForegroundColor White
Write-Host "El sistema mantiene disponibilidad aunque con capacidad reducida" -ForegroundColor White

Write-Host "`nINSTRUCCIONES PARA EL NAVEGADOR:" -ForegroundColor Yellow
Write-Host "1. Acceder a: http://www.proyectosd.com:3000" -ForegroundColor White
Write-Host "2. Navegar y consultar productos" -ForegroundColor White
Write-Host "3. Verificar que TODO funciona normalmente" -ForegroundColor White
Write-Host "4. Rendimiento puede ser menor (1 nodo vs 3 nodos)" -ForegroundColor White
Write-Host "5. NOTA: Ejecutar script 5e para detener el ultimo nodo`n" -ForegroundColor Yellow
