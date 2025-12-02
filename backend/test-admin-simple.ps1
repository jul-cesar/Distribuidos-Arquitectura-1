Write-Host "`n=== PRUEBA RAPIDA: Panel de Admin ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "[PASO 1] Verificando que los servicios esten activos..." -ForegroundColor Yellow
$frontendLB = Test-NetConnection -ComputerName localhost -Port 3000 -WarningAction SilentlyContinue
$backendLB = Test-NetConnection -ComputerName localhost -Port 4000 -WarningAction SilentlyContinue

if ($frontendLB.TcpTestSucceeded) {
    Write-Host "  ✅ Frontend Load Balancer (puerto 3000): ACTIVO" -ForegroundColor Green
} else {
    Write-Host "  ❌ Frontend Load Balancer (puerto 3000): NO RESPONDE" -ForegroundColor Red
    exit 1
}

if ($backendLB.TcpTestSucceeded) {
    Write-Host "  ✅ Backend Load Balancer (puerto 4000): ACTIVO" -ForegroundColor Green
} else {
    Write-Host "  ❌ Backend Load Balancer (puerto 4000): NO RESPONDE" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[PASO 2] Probando acceso a productos (sin autenticacion)..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/v2/storefront/products?per_page=3" -Method Get
    $productCount = $response.data.Count
    Write-Host "  ✅ API Storefront funciona: $productCount productos obtenidos" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Error accediendo al API: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== INSTRUCCIONES PARA USAR EL PANEL DE ADMIN ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Abre tu navegador y ve a:" -ForegroundColor White
Write-Host "   http://localhost:3000/login.html" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Ingresa las credenciales:" -ForegroundColor White
Write-Host "   Email:    admin@example.com" -ForegroundColor Yellow
Write-Host "   Password: spree123" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. Despues de iniciar sesion, ve a:" -ForegroundColor White
Write-Host "   http://localhost:3000/admin.html" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. IMPORTANTE: Usa SIEMPRE el puerto 3000" -ForegroundColor Yellow
Write-Host "   - El frontend (puerto 3000) automaticamente redirige las peticiones API al backend (puerto 4000)" -ForegroundColor Gray
Write-Host "   - Esto es parte de la arquitectura de Load Balancing" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Si ves errores de permisos:" -ForegroundColor White
Write-Host "   - Abre la consola del navegador (F12)" -ForegroundColor Gray
Write-Host "   - Ve a la pestana Console" -ForegroundColor Gray
Write-Host "   - Mira los mensajes de error en rojo" -ForegroundColor Gray
Write-Host "   - Compartelos para poder ayudarte" -ForegroundColor Gray
Write-Host ""
