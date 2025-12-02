Write-Host "Probando endpoint /api/v1/admin_products..." -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/api/v1/admin_products" `
        -Method Get `
        -Headers @{"Authorization"="Bearer test"}
    
    Write-Host "✅ Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Contenido: $($response.Content)" -ForegroundColor White
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "Status HTTP: $statusCode" -ForegroundColor $(if($statusCode -eq 401){"Green"}else{"Yellow"})
    
    if ($statusCode -eq 401) {
        Write-Host "" 
        Write-Host "🎉🎉🎉 EXITO! El endpoint funciona correctamente" -ForegroundColor Green
        Write-Host "El codigo 401 significa que el endpoint existe y requiere autenticacion valida" -ForegroundColor White
        Write-Host ""
        Write-Host "Ahora puedes usar el panel de admin en: http://localhost:3000/admin.html" -ForegroundColor Cyan
    } elseif ($statusCode -eq 404) {
        Write-Host "❌ Error 404: El endpoint no existe" -ForegroundColor Red
    } else {
        Write-Host "⚠️  Codigo inesperado: $statusCode" -ForegroundColor Yellow
        Write-Host "Detalles: $($_.Exception.Message)" -ForegroundColor Gray
    }
}
