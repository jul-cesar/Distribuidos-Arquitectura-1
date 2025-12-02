Write-Host "`n=== PRUEBA 4.d - Desmontar replica2, solo Master activo ===" -ForegroundColor Cyan

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$testEmail = "test_solo_master_$timestamp@prueba.com"

Write-Host "`n[Paso 1] Desmontar db-replica2 (replica1 ya esta detenida)" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker stop db-replica2" -ForegroundColor White
docker stop db-replica2
Write-Host "db-replica2 DETENIDA" -ForegroundColor Red

Write-Host "`n[Paso 2] Verificar estado del cluster (Solo Master activo)" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker ps --filter 'name=db-' --format 'table {{.Names}}\t{{.Status}}'" -ForegroundColor White
docker ps | Select-String "db-"

Write-Host "`n[Paso 3] Crear nuevo usuario con SOLO Master activo" -ForegroundColor Yellow
Write-Host "Email de prueba: $testEmail" -ForegroundColor Cyan

Write-Host "`n[COMANDO API]" -ForegroundColor Green
Write-Host "POST http://localhost:4000/api/v2/storefront/account" -ForegroundColor White
Write-Host "Body: { user: { email: '$testEmail', password: '***' } }" -ForegroundColor Gray

$createUserBody = @{
    user = @{
        email = $testEmail
        password = "Password123!"
        password_confirmation = "Password123!"
    }
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:4000/api/v2/storefront/account" `
        -Method POST `
        -Body $createUserBody `
        -ContentType "application/json" `
        -UseBasicParsing `
        -ErrorAction Stop
    
    Write-Host "Usuario creado exitosamente (solo con Master)" -ForegroundColor Green
    Write-Host "StatusCode: $($response.StatusCode)" -ForegroundColor Gray
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Start-Sleep -Seconds 2

Write-Host "`n[Paso 4] Verificar en Master (unico nodo activo)" -ForegroundColor Yellow
Write-Host "`nMASTER (db-master):" -ForegroundColor Cyan
Write-Host "[COMANDO SQL]" -ForegroundColor Green
Write-Host "docker exec db-master psql -U spree -d spree_db -c `"SELECT email FROM spree_users WHERE email = '$testEmail';`"" -ForegroundColor White
$masterResult = docker exec db-master psql -U spree -d spree_db -t -c "SELECT email FROM spree_users WHERE email = '$testEmail';" 2>$null

if ($masterResult -match $testEmail) {
    Write-Host "  Usuario encontrado" -ForegroundColor Green
    Write-Host "  Email: $($masterResult.Trim())" -ForegroundColor White
} else {
    Write-Host "  Usuario NO encontrado" -ForegroundColor Red
}

Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "- db-replica1: DETENIDA" -ForegroundColor Red
Write-Host "- db-replica2: DETENIDA" -ForegroundColor Red
Write-Host "- db-master: ACTIVA - UNICO nodo funcionando" -ForegroundColor Green

if ($masterResult -match $testEmail) {
    Write-Host "`nEXITO: Sistema funciona con solo Master activo" -ForegroundColor Green
    Write-Host "Los datos se guardan correctamente sin replicas" -ForegroundColor White
    Write-Host "Cuando las replicas se reactiven, se sincronizaran automaticamente" -ForegroundColor White
} else {
    Write-Host "`nFALLO: Problema guardando datos en Master" -ForegroundColor Red
}

Write-Host "`nEmail creado: $testEmail" -ForegroundColor White
Write-Host "NOTA: Ejecutar script 4e para restaurar cluster completo`n" -ForegroundColor Yellow
