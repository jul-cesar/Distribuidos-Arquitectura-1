# Prueba 6a: Registro y Verificacion de Usuario en Cluster de BD
# Objetivo: Registrar un usuario en el frontend y verificar que existe
#           en todos los nodos del cluster de base de datos

Write-Host "`n===============================================================" -ForegroundColor Cyan
Write-Host "  PRUEBA 6a: REPLICACION DE USUARIOS EN CLUSTER DE BD" -ForegroundColor Cyan
Write-Host "===============================================================`n" -ForegroundColor Cyan

# PASO 1: REGISTRAR NUEVO USUARIO
Write-Host "PASO 1: REGISTRANDO NUEVO USUARIO EN EL FRONTEND`n" -ForegroundColor Yellow

$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$randomId = Get-Random -Minimum 1000 -Maximum 9999
$userEmail = "test_user_${timestamp}_${randomId}@example.com"
$userPassword = "TestPassword123!"

Write-Host "Email del usuario: $userEmail" -ForegroundColor Cyan
Write-Host "Password: $userPassword`n" -ForegroundColor Cyan

$registerBody = @{
    user = @{
        email = $userEmail
        password = $userPassword
        password_confirmation = $userPassword
    }
} | ConvertTo-Json

Write-Host "Enviando peticion de registro..." -ForegroundColor Gray

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/v2/storefront/account" `
                                  -Method POST `
                                  -Body $registerBody `
                                  -ContentType "application/json" `
                                  -ErrorAction Stop
    
    $userId = $response.data.id
    Write-Host "Usuario registrado exitosamente (ID: $userId)`n" -ForegroundColor Green
} catch {
    Write-Host "Error al registrar usuario: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Esperando 3 segundos para la replicacion..." -ForegroundColor Gray
Start-Sleep -Seconds 3

# PASO 2: VERIFICAR EN EL NODO MASTER
Write-Host "`nPASO 2: VERIFICANDO EN NODO MASTER (db-master)`n" -ForegroundColor Yellow

$sqlQuery = "SELECT id, email, created_at FROM spree_users WHERE email = '$userEmail';"

Write-Host "Ejecutando consulta SQL en db-master..." -ForegroundColor Gray
try {
    $masterResult = docker exec db-master psql -U spree -d spree_db -t -A -c "$sqlQuery" 2>&1
    
    if ($masterResult -match '\|') {
        $fields = $masterResult -split '\|'
        Write-Host "Usuario encontrado en MASTER" -ForegroundColor Green
        Write-Host "  ID: $($fields[0])" -ForegroundColor White
        Write-Host "  Email: $($fields[1])" -ForegroundColor White
        Write-Host "  Creado: $($fields[2])`n" -ForegroundColor White
    } else {
        Write-Host "Usuario NO encontrado en MASTER`n" -ForegroundColor Red
    }
} catch {
    Write-Host "Error al consultar MASTER: $($_.Exception.Message)`n" -ForegroundColor Red
}

# PASO 3: VERIFICAR EN REPLICA 1
Write-Host "PASO 3: VERIFICANDO EN REPLICA 1 (db-replica1)`n" -ForegroundColor Yellow

Write-Host "Ejecutando consulta SQL en db-replica1..." -ForegroundColor Gray
try {
    $replica1Result = docker exec db-replica1 psql -U spree -d spree_db -t -A -c "$sqlQuery" 2>&1
    
    if ($replica1Result -match '\|') {
        $fields = $replica1Result -split '\|'
        Write-Host "Usuario encontrado en REPLICA 1" -ForegroundColor Green
        Write-Host "  ID: $($fields[0])" -ForegroundColor White
        Write-Host "  Email: $($fields[1])" -ForegroundColor White
        Write-Host "  Creado: $($fields[2])`n" -ForegroundColor White
    } else {
        Write-Host "Usuario NO encontrado en REPLICA 1`n" -ForegroundColor Red
    }
} catch {
    Write-Host "Error al consultar REPLICA 1: $($_.Exception.Message)`n" -ForegroundColor Red
}

# PASO 4: VERIFICAR EN REPLICA 2
Write-Host "PASO 4: VERIFICANDO EN REPLICA 2 (db-replica2)`n" -ForegroundColor Yellow

Write-Host "Ejecutando consulta SQL en db-replica2..." -ForegroundColor Gray
try {
    $replica2Result = docker exec db-replica2 psql -U spree -d spree_production -t -A -c "$sqlQuery" 2>&1
    
    if ($replica2Result -match '\|') {
        $fields = $replica2Result -split '\|'
        Write-Host "Usuario encontrado en REPLICA 2" -ForegroundColor Green
        Write-Host "  ID: $($fields[0])" -ForegroundColor White
        Write-Host "  Email: $($fields[1])" -ForegroundColor White
        Write-Host "  Creado: $($fields[2])`n" -ForegroundColor White
    } else {
        Write-Host "Usuario NO encontrado en REPLICA 2`n" -ForegroundColor Red
    }
} catch {
    Write-Host "Error al consultar REPLICA 2: $($_.Exception.Message)`n" -ForegroundColor Red
}

# RESUMEN
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "RESUMEN DE LA PRUEBA" -ForegroundColor Cyan
Write-Host "===============================================================`n" -ForegroundColor Cyan

$masterOk = $masterResult -match '\|'
$replica1Ok = $replica1Result -match '\|'
$replica2Ok = $replica2Result -match '\|'

Write-Host "Estado de replicacion:" -ForegroundColor Yellow
Write-Host "  Master (db-master):      $(if ($masterOk) { 'OK' } else { 'FALLO' })" -ForegroundColor $(if ($masterOk) { 'Green' } else { 'Red' })
Write-Host "  Replica 1 (db-replica1): $(if ($replica1Ok) { 'OK' } else { 'FALLO' })" -ForegroundColor $(if ($replica1Ok) { 'Green' } else { 'Red' })
Write-Host "  Replica 2 (db-replica2): $(if ($replica2Ok) { 'OK' } else { 'FALLO' })" -ForegroundColor $(if ($replica2Ok) { 'Green' } else { 'Red' })

Write-Host ""

if ($masterOk -and $replica1Ok -and $replica2Ok) {
    Write-Host "===============================================================" -ForegroundColor Green
    Write-Host "                 PRUEBA EXITOSA" -ForegroundColor Green
    Write-Host "  El usuario fue replicado en todos los nodos del cluster" -ForegroundColor Green
    Write-Host "===============================================================" -ForegroundColor Green
} else {
    Write-Host "===============================================================" -ForegroundColor Red
    Write-Host "                 PRUEBA FALLIDA" -ForegroundColor Red
    Write-Host "  El usuario NO fue replicado en todos los nodos" -ForegroundColor Red
    Write-Host "===============================================================" -ForegroundColor Red
}

Write-Host "`nDatos de prueba:" -ForegroundColor Cyan
Write-Host "  Email: $userEmail" -ForegroundColor White
Write-Host "  Password: $userPassword" -ForegroundColor White
Write-Host "  ID: $userId`n" -ForegroundColor White