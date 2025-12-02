Write-Host "`n=== PRUEBA 4.b - Validar sincronizacion creando usuario ===" -ForegroundColor Cyan

Write-Host "`n[Paso 0] Verificar que los 3 nodos esten activos" -ForegroundColor Yellow
$runningDbs = docker ps --filter "name=db-" --format "{{.Names}}" | Measure-Object | Select-Object -ExpandProperty Count
if ($runningDbs -lt 3) {
    Write-Host "ADVERTENCIA: Solo $runningDbs nodos activos. Iniciando nodos detenidos..." -ForegroundColor Yellow
    docker start db-master db-replica1 db-replica2 2>$null
    Write-Host "Esperando a que los nodos se conecten..." -ForegroundColor Gray
    Start-Sleep -Seconds 8
}
docker ps --filter "name=db-" --format "table {{.Names}}\t{{.Status}}" | Write-Host -ForegroundColor Gray

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$testEmail = "testuser_$timestamp@prueba.com"

Write-Host "`n[Paso 1] Crear nuevo usuario via API de Spree" -ForegroundColor Yellow
Write-Host "Email de prueba: $testEmail" -ForegroundColor Cyan

Write-Host "`n[COMANDO API]" -ForegroundColor Green
Write-Host "POST http://localhost:4000/api/v2/storefront/account" -ForegroundColor White
Write-Host "Content-Type: application/json" -ForegroundColor Gray
Write-Host "Body: { user: { email: '$testEmail', password: '***', password_confirmation: '***' } }" -ForegroundColor Gray

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
    
    Write-Host "Usuario creado exitosamente!" -ForegroundColor Green
    Write-Host "StatusCode: $($response.StatusCode)" -ForegroundColor Gray
} catch {
    Write-Host "Error creando usuario: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Continuando con verificacion de todos modos..." -ForegroundColor Yellow
}

Start-Sleep -Seconds 2

Write-Host "`n[Paso 2] Verificar usuario en MASTER (db-master)" -ForegroundColor Yellow
Write-Host "[COMANDO SQL]" -ForegroundColor Green
Write-Host "docker exec db-master psql -U spree -d spree_db -c `"SELECT email FROM spree_users WHERE email = '$testEmail';`"" -ForegroundColor White
$masterResult = docker exec db-master psql -U spree -d spree_db -t -c "SELECT email FROM spree_users WHERE email = '$testEmail';" 2>$null

if ($masterResult -match $testEmail) {
    Write-Host "MASTER: Usuario encontrado" -ForegroundColor Green
    Write-Host "  Email: $($masterResult.Trim())" -ForegroundColor White
} else {
    Write-Host "MASTER: Usuario NO encontrado" -ForegroundColor Red
}

Write-Host "`n[Paso 3] Verificar usuario en REPLICA 1 (db-replica1)" -ForegroundColor Yellow
Write-Host "[COMANDO SQL]" -ForegroundColor Green
Write-Host "docker exec db-replica1 psql -U spree -d spree_db -c `"SELECT email FROM spree_users WHERE email = '$testEmail';`"" -ForegroundColor White
$replica1Result = docker exec db-replica1 psql -U spree -d spree_db -t -c "SELECT email FROM spree_users WHERE email = '$testEmail';" 2>$null

if ($replica1Result -match $testEmail) {
    Write-Host "REPLICA 1: Usuario encontrado (SINCRONIZADO)" -ForegroundColor Green
    Write-Host "  Email: $($replica1Result.Trim())" -ForegroundColor White
} else {
    Write-Host "REPLICA 1: Usuario NO encontrado (NO SINCRONIZADO)" -ForegroundColor Red
}

Write-Host "`n[Paso 4] Verificar usuario en REPLICA 2 (db-replica2)" -ForegroundColor Yellow
Write-Host "[COMANDO SQL]" -ForegroundColor Green
Write-Host "docker exec db-replica2 psql -U spree -d spree_db -c `"SELECT email FROM spree_users WHERE email = '$testEmail';`"" -ForegroundColor White
$replica2Result = docker exec db-replica2 psql -U spree -d spree_db -t -c "SELECT email FROM spree_users WHERE email = '$testEmail';" 2>$null

if ($replica2Result -match $testEmail) {
    Write-Host "REPLICA 2: Usuario encontrado (SINCRONIZADO)" -ForegroundColor Green
    Write-Host "  Email: $($replica2Result.Trim())" -ForegroundColor White
} else {
    Write-Host "REPLICA 2: Usuario NO encontrado (NO SINCRONIZADO)" -ForegroundColor Red
}

Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
if ($masterResult -match $testEmail -and $replica1Result -match $testEmail -and $replica2Result -match $testEmail) {
    Write-Host "EXITO: Usuario replicado en los 3 nodos del cluster" -ForegroundColor Green
} else {
    Write-Host "FALLO: Usuario NO esta en todos los nodos" -ForegroundColor Red
}

Write-Host "`nEmail de prueba creado: $testEmail" -ForegroundColor White
Write-Host "(Guardar este email para verificaciones posteriores)`n" -ForegroundColor Yellow
