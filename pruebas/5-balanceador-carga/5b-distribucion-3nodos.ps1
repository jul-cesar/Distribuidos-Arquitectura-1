Write-Host "`n=== PRUEBA 5.b - Distribucion de solicitudes entre 3 nodos ===" -ForegroundColor Cyan

Write-Host "`n[Paso 1] Verificar que los 3 nodos Frontend esten activos" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker ps --filter 'name=frontend-' --format 'table {{.Names}}\t{{.Status}}'" -ForegroundColor White
docker ps --filter "name=frontend-" --format "table {{.Names}}`t{{.Status}}"

Write-Host "`n[Paso 2] Hacer 6 solicitudes HTTP para ver la distribucion Round Robin" -ForegroundColor Yellow
Write-Host "Cada solicitud deberia ir a un nodo diferente en orden rotativo" -ForegroundColor Cyan

for ($i = 1; $i -le 6; $i++) {
    Write-Host "`n--- Solicitud $i ---" -ForegroundColor White
    Write-Host "[COMANDO HTTP]" -ForegroundColor Green
    Write-Host "Invoke-WebRequest -Uri 'http://localhost:3000' -Method GET" -ForegroundColor White
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET -UseBasicParsing -TimeoutSec 5
        Write-Host "StatusCode: $($response.StatusCode)" -ForegroundColor Green
        
        # Buscar el titulo de la pagina para confirmar que responde
        if ($response.Content -match '<title>([^<]+)</title>') {
            Write-Host "Pagina: $($matches[1])" -ForegroundColor Gray
        }
        
        Write-Host "Solicitud procesada exitosamente" -ForegroundColor Green
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host "`n[Paso 3] Verificar logs de Nginx para confirmar distribucion" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker logs frontend-lb --tail 10" -ForegroundColor White
Write-Host "`n--- ULTIMAS 10 LINEAS DEL LOG ---" -ForegroundColor Cyan
docker logs frontend-lb --tail 10

Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Se realizaron 6 solicitudes HTTP al balanceador (puerto 3000)" -ForegroundColor White
Write-Host "Nginx distribuye las solicitudes usando LEAST_CONN:" -ForegroundColor White
Write-Host "  - Cada solicitud va al servidor con menos conexiones activas" -ForegroundColor Gray
Write-Host "  - Si todos tienen la misma carga, actua como Round Robin" -ForegroundColor Gray
Write-Host "  - Balanceo mas inteligente que Round Robin simple" -ForegroundColor Gray

Write-Host "`nINSTRUCCIONES PARA EL NAVEGADOR:" -ForegroundColor Yellow
Write-Host "1. Abrir navegador en el cliente" -ForegroundColor White
Write-Host "2. Acceder a: http://www.proyectosd.com:3000" -ForegroundColor White
Write-Host "3. Recargar la pagina varias veces (F5)" -ForegroundColor White
Write-Host "4. Cada recarga sera atendida por el servidor menos ocupado" -ForegroundColor White
Write-Host "5. Para ver cual nodo responde, puedes usar Developer Tools (F12) -> Network`n" -ForegroundColor White
