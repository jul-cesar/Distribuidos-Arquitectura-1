Write-Host "`n=== PRUEBA 5.a - Identificar balanceador de carga y algoritmo ===" -ForegroundColor Cyan

Write-Host "`n[Paso 1] Identificar el balanceador de carga" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker ps --filter 'name=frontend-lb' --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'" -ForegroundColor White
docker ps --filter "name=frontend-lb" --format "table {{.Names}}`t{{.Image}}`t{{.Status}}"

Write-Host "`n[Paso 2] Verificar nodos Frontend activos" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker ps --filter 'name=frontend-' --format 'table {{.Names}}\t{{.Status}}'" -ForegroundColor White
docker ps --filter "name=frontend-" --format "table {{.Names}}`t{{.Status}}"

Write-Host "`n[Paso 3] Mostrar configuracion del balanceador Nginx" -ForegroundColor Yellow
Write-Host "[COMANDO]" -ForegroundColor Green
Write-Host "docker exec frontend-lb cat /etc/nginx/nginx.conf" -ForegroundColor White
Write-Host "`n--- CONFIGURACION NGINX ---" -ForegroundColor Cyan
docker exec frontend-lb cat /etc/nginx/nginx.conf

Write-Host "`n=== ANALISIS DE LA CONFIGURACION ===" -ForegroundColor Cyan
Write-Host "Balanceador: NGINX" -ForegroundColor White
Write-Host "Puerto expuesto: 3000 (mapeado a puerto 80 interno)" -ForegroundColor White
Write-Host "Nodos backend: frontend-1, frontend-2, frontend-3" -ForegroundColor White
Write-Host "`nAlgoritmo de balanceo configurado:" -ForegroundColor Yellow
Write-Host "  - LEAST_CONN (Least Connections)" -ForegroundColor Green
Write-Host "  - Envia cada solicitud al servidor con MENOS conexiones activas" -ForegroundColor White
Write-Host "  - Mas eficiente que Round Robin para cargas desiguales" -ForegroundColor Gray
Write-Host "  - Ejemplo: Si frontend-1 tiene 5 conexiones y frontend-2 tiene 2," -ForegroundColor Gray
Write-Host "    la nueva solicitud ira a frontend-2" -ForegroundColor Gray

Write-Host "`nOtros algoritmos disponibles en Nginx:" -ForegroundColor Yellow
Write-Host "  - round_robin (default): distribucion secuencial rotativa" -ForegroundColor Gray
Write-Host "  - ip_hash: mismo cliente siempre va al mismo servidor" -ForegroundColor Gray
Write-Host "  - least_time: envia al servidor con menor tiempo de respuesta" -ForegroundColor Gray

Write-Host "`nConfiguracion de salud (Health Check):" -ForegroundColor Yellow
Write-Host "  - max_fails=3: marca servidor como caido despues de 3 fallos" -ForegroundColor Gray
Write-Host "  - fail_timeout=30s: reintenta servidor caido despues de 30 segundos" -ForegroundColor Gray

Write-Host "`nAcceso al sistema:" -ForegroundColor Yellow
Write-Host "  Desde navegador: http://www.proyectosd.com:3000" -ForegroundColor White
Write-Host "  Desde localhost: http://localhost:3000`n" -ForegroundColor White
