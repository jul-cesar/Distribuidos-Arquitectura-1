Write-Host "`n=== PRUEBA 2.c - Acceso via nombre DNS desde navegador ===" -ForegroundColor Cyan

Write-Host "`n[Test] Acceder a la aplicacion usando el nombre de dominio" -ForegroundColor Yellow

Write-Host "`nPASOS:" -ForegroundColor Cyan
Write-Host "1. Configurar DNS en el sistema:" -ForegroundColor White
Write-Host "   - Windows: Panel de Control > Red > Adaptador > Propiedades IPv4" -ForegroundColor Gray
Write-Host "   - Establecer DNS preferido: 127.0.0.1" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Agregar entrada en archivo hosts (alternativo):" -ForegroundColor White
Write-Host "   - Abrir: C:\Windows\System32\drivers\etc\hosts" -ForegroundColor Gray
Write-Host "   - Agregar: 192.168.1.66  www.proyectosd.com proyectosd.com" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Abrir navegador y acceder a:" -ForegroundColor White
Write-Host "   http://www.proyectosd.com:3000" -ForegroundColor Green
Write-Host ""

Write-Host "[Comando] Probando acceso via curl..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "EXITO: La aplicacion responde (StatusCode 200)" -ForegroundColor Green
        Write-Host "La pagina principal deberia mostrarse en el navegador" -ForegroundColor Green
    }
} catch {
    Write-Host "FALLO: La aplicacion no responde" -ForegroundColor Red
}

Write-Host "`nRESULTADO ESPERADO:" -ForegroundColor Cyan
Write-Host "- Se muestra la pagina principal de Spree Commerce" -ForegroundColor White
Write-Host "- El frontend-lb distribuye la peticion entre frontend-1, 2 y 3" -ForegroundColor White
Write-Host "- La URL muestra: http://www.proyectosd.com:3000`n" -ForegroundColor White

Write-Host "EXPLICACION TECNICA:" -ForegroundColor Cyan
Write-Host "1. Browser consulta DNS: www.proyectosd.com -> 192.168.1.66" -ForegroundColor White
Write-Host "2. Peticion llega al puerto 3000 (frontend-lb)" -ForegroundColor White
Write-Host "3. Nginx LB distribuye a frontend-1, 2 o 3" -ForegroundColor White
Write-Host "4. Frontend muestra la pagina de Spree`n" -ForegroundColor White
