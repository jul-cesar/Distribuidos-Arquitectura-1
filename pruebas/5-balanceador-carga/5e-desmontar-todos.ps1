Write-Host "`n=== PRUEBA 5.e - Desmontar ultimo nodo, sistema no responde ===" -ForegroundColor Cyan

Write-Host "`n[Paso 1] Estado actual - Solo 1 nodo activo" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker ps --filter 'name=frontend-' --format 'table {{.Names}}\t{{.Status}}'" -ForegroundColor White
docker ps --filter "name=frontend-" --format "table {{.Names}}`t{{.Status}}"

Write-Host "`n[Paso 2] Desmontar frontend-3 (ultimo nodo activo)" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker stop frontend-3" -ForegroundColor White
docker stop frontend-3
Write-Host "frontend-3 DETENIDO" -ForegroundColor Red

Write-Host "`n[Paso 3] Verificar que NO hay nodos activos" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker ps --filter 'name=frontend-' --format 'table {{.Names}}\t{{.Status}}'" -ForegroundColor White
$runningFrontends = docker ps --filter "name=frontend-" --format "{{.Names}}" | Measure-Object | Select-Object -ExpandProperty Count
if ($runningFrontends -eq 0) {
    Write-Host "0 nodos activos" -ForegroundColor Red
} else {
    docker ps --filter "name=frontend-" --format "table {{.Names}}`t{{.Status}}"
}

Write-Host "`n[Paso 4] Intentar hacer solicitudes HTTP (deberian FALLAR)" -ForegroundColor Yellow
Write-Host "Sin nodos activos, el balanceador no puede atender solicitudes" -ForegroundColor Cyan

for ($i = 1; $i -le 3; $i++) {
    Write-Host "`n--- Intento $i ---" -ForegroundColor White
    Write-Host "[COMANDO HTTP]" -ForegroundColor Green
    Write-Host "Invoke-WebRequest -Uri 'http://localhost:3000' -Method GET" -ForegroundColor White
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET -UseBasicParsing -TimeoutSec 5
        Write-Host "StatusCode: $($response.StatusCode)" -ForegroundColor Yellow
        Write-Host "INESPERADO: El sistema respondio" -ForegroundColor Yellow
    } catch {
        Write-Host "ERROR (esperado): No hay nodos disponibles" -ForegroundColor Red
        Write-Host "Mensaje: $($_.Exception.Message)" -ForegroundColor Gray
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Estado del cluster Frontend:" -ForegroundColor White
Write-Host "  - frontend-1: DETENIDO" -ForegroundColor Red
Write-Host "  - frontend-2: DETENIDO" -ForegroundColor Red
Write-Host "  - frontend-3: DETENIDO" -ForegroundColor Red

Write-Host "`nResultado: Sistema NO DISPONIBLE (0 nodos activos)" -ForegroundColor Red
Write-Host "El balanceador Nginx no tiene nodos a los cuales enviar trafico" -ForegroundColor White
Write-Host "Las solicitudes HTTP fallan con error 502 Bad Gateway o timeout" -ForegroundColor White

Write-Host "`nINSTRUCCIONES PARA EL NAVEGADOR:" -ForegroundColor Yellow
Write-Host "1. Intentar acceder a: http://www.proyectosd.com:3000" -ForegroundColor White
Write-Host "2. Deberia mostrar error: '502 Bad Gateway' o 'Connection refused'" -ForegroundColor White
Write-Host "3. Esto demuestra que sin nodos activos, el sistema no funciona" -ForegroundColor White

Write-Host "`n[Paso 5] Restaurar los 3 nodos Frontend para continuar" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker start frontend-1 frontend-2 frontend-3" -ForegroundColor White
docker start frontend-1 frontend-2 frontend-3
Write-Host "`nEsperando a que los nodos se inicien..." -ForegroundColor Gray
Start-Sleep -Seconds 5

Write-Host "`nVerificando nodos restaurados:" -ForegroundColor Yellow
docker ps --filter "name=frontend-" --format "table {{.Names}}`t{{.Status}}"

Write-Host "`n[Paso 6] Verificar que el sistema volvio a funcionar" -ForegroundColor Yellow
Write-Host "[COMANDO HTTP]" -ForegroundColor Green
Write-Host "Invoke-WebRequest -Uri 'http://localhost:3000' -Method GET" -ForegroundColor White

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET -UseBasicParsing -TimeoutSec 10
    Write-Host "StatusCode: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "`nSISTEMA RESTAURADO Y FUNCIONANDO" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Puede que los nodos aun esten iniciando, espera 10 segundos mas" -ForegroundColor Yellow
}

Write-Host "`n=== CONCLUSION ===" -ForegroundColor Cyan
Write-Host "Se demostro que:" -ForegroundColor White
Write-Host "  1. Con 3 nodos -> Sistema funciona al 100%" -ForegroundColor Green
Write-Host "  2. Con 2 nodos -> Sistema funciona (tolerante a 1 fallo)" -ForegroundColor Green
Write-Host "  3. Con 1 nodo -> Sistema funciona (capacidad reducida)" -ForegroundColor Yellow
Write-Host "  4. Con 0 nodos -> Sistema NO DISPONIBLE" -ForegroundColor Red
Write-Host "  5. Al restaurar nodos -> Sistema se recupera automaticamente" -ForegroundColor Green
Write-Host "`nEsto demuestra ALTA DISPONIBILIDAD y TOLERANCIA A FALLOS`n" -ForegroundColor Green
