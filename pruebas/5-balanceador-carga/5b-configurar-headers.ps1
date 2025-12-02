Write-Host "`n=== PRUEBA 5.b - Evidenciar distribucion en el navegador ===" -ForegroundColor Cyan

Write-Host "`n[Paso 1] Verificar que los 3 nodos Frontend esten activos" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker ps --filter 'name=frontend-' --format 'table {{.Names}}\t{{.Status}}'" -ForegroundColor White
docker ps --filter "name=frontend-" --format "table {{.Names}}`t{{.Status}}"

Write-Host "`n[Paso 2] Agregar header temporal para identificar cada servidor" -ForegroundColor Yellow
Write-Host "Modificando configuracion de Nginx en cada frontend..." -ForegroundColor Cyan

# Agregar header X-Served-By a cada frontend
docker exec frontend-1 sh -c "echo 'add_header X-Served-By frontend-1 always;' >> /etc/nginx/conf.d/default.conf && nginx -s reload" 2>$null
docker exec frontend-2 sh -c "echo 'add_header X-Served-By frontend-2 always;' >> /etc/nginx/conf.d/default.conf && nginx -s reload" 2>$null
docker exec frontend-3 sh -c "echo 'add_header X-Served-By frontend-3 always;' >> /etc/nginx/conf.d/default.conf && nginx -s reload" 2>$null

Write-Host "Headers configurados en los 3 frontends" -ForegroundColor Green

Write-Host "`n[Paso 3] Hacer 12 solicitudes y mostrar que servidor respondio" -ForegroundColor Yellow
Write-Host "Cada solicitud mostrara el header X-Served-By indicando el nodo" -ForegroundColor Cyan

$distribucion = @{
    "frontend-1" = 0
    "frontend-2" = 0
    "frontend-3" = 0
}

for ($i = 1; $i -le 12; $i++) {
    Write-Host "`n--- Solicitud $i ---" -ForegroundColor White
    Write-Host "[COMANDO HTTP]" -ForegroundColor Green
    Write-Host "Invoke-WebRequest -Uri 'http://localhost:3000' -Method GET" -ForegroundColor White
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET -UseBasicParsing -TimeoutSec 5
        $servidor = $response.Headers["X-Served-By"]
        
        if ($servidor) {
            Write-Host "Respondio: $servidor" -ForegroundColor Cyan
            $distribucion[$servidor]++
        } else {
            Write-Host "Respondio: (sin identificar)" -ForegroundColor Gray
        }
        
        Write-Host "StatusCode: $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Start-Sleep -Milliseconds 300
}

Write-Host "`n[Paso 4] Resumen de distribucion" -ForegroundColor Yellow
Write-Host "`n=== ESTADISTICAS DE BALANCEO ===" -ForegroundColor Cyan
Write-Host "Total de solicitudes: 12" -ForegroundColor White
Write-Host "`nDistribucion por nodo:" -ForegroundColor White
foreach ($nodo in $distribucion.Keys | Sort-Object) {
    $count = $distribucion[$nodo]
    $porcentaje = [math]::Round(($count / 12) * 100, 1)
    $barra = "█" * $count
    Write-Host "  $nodo : $count solicitudes ($porcentaje%) $barra" -ForegroundColor Cyan
}

Write-Host "`n=== INSTRUCCIONES PARA EVIDENCIAR EN EL NAVEGADOR ===" -ForegroundColor Yellow
Write-Host "`nMETODO 1: Usar Developer Tools (F12)" -ForegroundColor White
Write-Host "1. Abrir navegador en el cliente" -ForegroundColor Gray
Write-Host "2. Acceder a: http://www.proyectosd.com:3000" -ForegroundColor Gray
Write-Host "3. Presionar F12 para abrir Developer Tools" -ForegroundColor Gray
Write-Host "4. Ir a la pestana 'Network' (Red)" -ForegroundColor Gray
Write-Host "5. Recargar la pagina (F5)" -ForegroundColor Gray
Write-Host "6. Hacer click en la primera solicitud (document)" -ForegroundColor Gray
Write-Host "7. En 'Response Headers' buscar: X-Served-By" -ForegroundColor Gray
Write-Host "8. Vera el nombre del frontend que respondio (frontend-1, frontend-2 o frontend-3)" -ForegroundColor Gray
Write-Host "9. Recargar varias veces y ver como cambia el header" -ForegroundColor Gray

Write-Host "`nMETODO 2: Usar curl desde el cliente (Ubuntu)" -ForegroundColor White
Write-Host "Ejecutar desde la terminal Ubuntu:" -ForegroundColor Gray
Write-Host "  for i in {1..10}; do curl -I http://www.proyectosd.com:3000 2>/dev/null | grep X-Served-By; done" -ForegroundColor Cyan

Write-Host "`nMETODO 3: Usar PowerShell desde Windows cliente" -ForegroundColor White
Write-Host "Ejecutar desde PowerShell:" -ForegroundColor Gray
Write-Host '  for ($i=1; $i -le 10; $i++) { (Invoke-WebRequest http://www.proyectosd.com:3000 -UseBasicParsing).Headers["X-Served-By"] }' -ForegroundColor Cyan

Write-Host "`n[Paso 5] Limpiar configuracion temporal" -ForegroundColor Yellow
Write-Host "Revertir cambios en la configuracion de Nginx..." -ForegroundColor Gray

# Revertir cambios (reiniciar contenedores para volver a config original)
docker restart frontend-1 frontend-2 frontend-3 | Out-Null
Write-Host "Configuracion revertida" -ForegroundColor Green

Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Se realizaron 12 solicitudes HTTP al balanceador (puerto 3000)" -ForegroundColor White
Write-Host "Nginx distribuye las solicitudes usando LEAST_CONN" -ForegroundColor White
Write-Host "El header X-Served-By identifica que frontend respondio cada solicitud" -ForegroundColor White
Write-Host "`nEvidencia visual disponible en:" -ForegroundColor Yellow
Write-Host "  - Developer Tools del navegador (F12 -> Network -> Response Headers)" -ForegroundColor Gray
Write-Host "  - curl -I desde terminal del cliente" -ForegroundColor Gray
Write-Host "  - PowerShell desde Windows cliente`n" -ForegroundColor Gray
