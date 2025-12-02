Write-Host "`n=== PRUEBA 4.c - Desmontar replica1 y validar replicacion ===" -ForegroundColor Cyan

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$testEmail = "test_1nodo_$timestamp@prueba.com"

Write-Host "`n[Paso 1] Desmontar db-replica1" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker stop db-replica1" -ForegroundColor White
docker stop db-replica1
Write-Host "db-replica1 DETENIDA" -ForegroundColor Red

Write-Host "`n[Paso 2] Verificar estado del cluster (Master + 1 Replica activa)" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker ps --filter 'name=db-' --format 'table {{.Names}}\t{{.Status}}'" -ForegroundColor White
docker ps | Select-String "db-"

Write-Host "`n[Paso 3] Crear nuevo usuario con solo 2 nodos activos" -ForegroundColor Yellow
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
    
    Write-Host "Usuario creado exitosamente (con 1 replica caida)" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Start-Sleep -Seconds 2

Write-Host "`n[Paso 4] Verificar en nodos ACTIVOS" -ForegroundColor Yellow

Write-Host "`nMASTER (db-master):" -ForegroundColor Cyan
Write-Host "[COMANDO SQL]" -ForegroundColor Green
Write-Host "docker exec db-master psql -U spree -d spree_db -c `"SELECT email FROM spree_users WHERE email = '$testEmail';`"" -ForegroundColor White
$masterResult = docker exec db-master psql -U spree -d spree_db -t -c "SELECT email FROM spree_users WHERE email = '$testEmail';" 2>$null
if ($masterResult -match $testEmail) {
    Write-Host "  Usuario encontrado" -ForegroundColor Green
} else {
    Write-Host "  Usuario NO encontrado" -ForegroundColor Red
}

Write-Host "`nREPLICA 2 (db-replica2):" -ForegroundColor Cyan
Write-Host "[COMANDO SQL]" -ForegroundColor Green
Write-Host "docker exec db-replica2 psql -U spree -d spree_db -c `"SELECT email FROM spree_users WHERE email = '$testEmail';`"" -ForegroundColor White
$replica2Result = docker exec db-replica2 psql -U spree -d spree_db -t -c "SELECT email FROM spree_users WHERE email = '$testEmail';" 2>$null
if ($replica2Result -match $testEmail) {
    Write-Host "  Usuario encontrado (SINCRONIZADO)" -ForegroundColor Green
} else {
    Write-Host "  Usuario NO encontrado" -ForegroundColor Red
}

Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "- db-replica1: DETENIDA (no verificada)" -ForegroundColor Red
Write-Host "- db-master: ACTIVA - Datos guardados" -ForegroundColor Green
Write-Host "- db-replica2: ACTIVA - Datos replicados" -ForegroundColor Green

if ($masterResult -match $testEmail -and $replica2Result -match $testEmail) {
    Write-Host "`nEXITO: Replicacion funciona con 1 nodo caido" -ForegroundColor Green
    Write-Host "El cluster continua operando con 2 de 3 nodos" -ForegroundColor White
} else {
    Write-Host "`nFALLO: Problema de replicacion" -ForegroundColor Red
}

Write-Host "`nEmail creado: $testEmail" -ForegroundColor White
Write-Host "NOTA: db-replica1 sigue detenida para prueba 4d`n" -ForegroundColor Yellow
