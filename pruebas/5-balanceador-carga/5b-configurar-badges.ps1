Write-Host "`n=== CONFIGURACION: Agregar identificador visual en cada frontend ===" -ForegroundColor Cyan

Write-Host "`n[OBJETIVO]" -ForegroundColor Yellow
Write-Host "Modificar cada frontend para que muestre visualmente cual servidor esta respondiendo" -ForegroundColor White
Write-Host "Esto permite evidenciar el balanceo de carga directamente desde el navegador" -ForegroundColor White

Write-Host "`n[Paso 1] Crear badge de identificacion para cada frontend" -ForegroundColor Yellow

# HTML para el badge que se inyectara en cada frontend
$badge1 = @'
<div style="position:fixed;top:10px;right:10px;background:#667eea;color:white;padding:10px 20px;border-radius:8px;font-weight:bold;z-index:9999;box-shadow:0 4px 6px rgba(0,0,0,0.3);font-size:14px;">
  SERVIDOR: FRONTEND-1
</div>
'@

$badge2 = @'
<div style="position:fixed;top:10px;right:10px;background:#48bb78;color:white;padding:10px 20px;border-radius:8px;font-weight:bold;z-index:9999;box-shadow:0 4px 6px rgba(0,0,0,0.3);font-size:14px;">
  SERVIDOR: FRONTEND-2
</div>
'@

$badge3 = @'
<div style="position:fixed;top:10px;right:10px;background:#ed8936;color:white;padding:10px 20px;border-radius:8px;font-weight:bold;z-index:9999;box-shadow:0 4px 6px rgba(0,0,0,0.3);font-size:14px;">
  SERVIDOR: FRONTEND-3
</div>
'@

Write-Host "`n[Paso 2] Inyectar badge en index.html de cada frontend" -ForegroundColor Yellow

# Frontend-1 (Azul)
Write-Host "Modificando frontend-1..." -ForegroundColor Cyan
docker exec frontend-1 sh -c "sed -i '/<body>/a $badge1' /usr/share/nginx/html/index.html"
Write-Host "  Badge AZUL agregado a frontend-1" -ForegroundColor Blue

# Frontend-2 (Verde)
Write-Host "Modificando frontend-2..." -ForegroundColor Cyan
docker exec frontend-2 sh -c "sed -i '/<body>/a $badge2' /usr/share/nginx/html/index.html"
Write-Host "  Badge VERDE agregado a frontend-2" -ForegroundColor Green

# Frontend-3 (Naranja)
Write-Host "Modificando frontend-3..." -ForegroundColor Cyan
docker exec frontend-3 sh -c "sed -i '/<body>/a $badge3' /usr/share/nginx/html/index.html"
Write-Host "  Badge NARANJA agregado a frontend-3" -ForegroundColor Yellow

Write-Host "`n[Paso 3] Verificar que los badges se agregaron correctamente" -ForegroundColor Yellow
$test1 = docker exec frontend-1 grep -c "FRONTEND-1" /usr/share/nginx/html/index.html
$test2 = docker exec frontend-2 grep -c "FRONTEND-2" /usr/share/nginx/html/index.html
$test3 = docker exec frontend-3 grep -c "FRONTEND-3" /usr/share/nginx/html/index.html

if ($test1 -gt 0 -and $test2 -gt 0 -and $test3 -gt 0) {
    Write-Host "Verificacion exitosa: Todos los badges estan configurados" -ForegroundColor Green
} else {
    Write-Host "ADVERTENCIA: Algunos badges no se configuraron correctamente" -ForegroundColor Yellow
}

Write-Host "`n=== CONFIGURACION COMPLETADA ===" -ForegroundColor Green

Write-Host "`n=== INSTRUCCIONES PARA EVIDENCIAR EL BALANCEO ===" -ForegroundColor Yellow

Write-Host "`n1. Desde el NAVEGADOR del CLIENTE:" -ForegroundColor White
Write-Host "   a) Abrir navegador en la maquina cliente (Ubuntu VM)" -ForegroundColor Gray
Write-Host "   b) Acceder a: http://www.proyectosd.com:3000" -ForegroundColor Cyan
Write-Host "   c) Observar en la esquina superior derecha un badge de color:" -ForegroundColor Gray
Write-Host "      - AZUL: 'SERVIDOR: FRONTEND-1'" -ForegroundColor Blue
Write-Host "      - VERDE: 'SERVIDOR: FRONTEND-2'" -ForegroundColor Green
Write-Host "      - NARANJA: 'SERVIDOR: FRONTEND-3'" -ForegroundColor Yellow
Write-Host "   d) Recargar la pagina (F5) varias veces" -ForegroundColor Gray
Write-Host "   e) El badge cambiara de color/servidor mostrando el balanceo" -ForegroundColor Gray

Write-Host "`n2. EVIDENCIA FOTOGRAFICA:" -ForegroundColor White
Write-Host "   - Tomar captura de pantalla con badge AZUL (frontend-1)" -ForegroundColor Gray
Write-Host "   - Recargar (F5) y tomar captura con badge VERDE (frontend-2)" -ForegroundColor Gray
Write-Host "   - Recargar (F5) y tomar captura con badge NARANJA (frontend-3)" -ForegroundColor Gray
Write-Host "   - Estas 3 capturas demuestran que el balanceador distribuye entre los 3 servidores" -ForegroundColor Gray

Write-Host "`n3. VIDEO DE DEMOSTRACION:" -ForegroundColor White
Write-Host "   - Grabar video mientras se recarga la pagina multiples veces" -ForegroundColor Gray
Write-Host "   - El badge cambiara de color/texto en cada recarga" -ForegroundColor Gray
Write-Host "   - Esto evidencia en tiempo real el algoritmo de balanceo" -ForegroundColor Gray

Write-Host "`n=== PARA REVERTIR LOS CAMBIOS ===" -ForegroundColor Yellow
Write-Host "Ejecutar: docker-compose restart frontend-1 frontend-2 frontend-3" -ForegroundColor Cyan
Write-Host "O usar el script: 5b-revertir-badges.ps1`n" -ForegroundColor Cyan
