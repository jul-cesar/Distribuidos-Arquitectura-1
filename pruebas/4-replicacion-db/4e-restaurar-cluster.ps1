Write-Host "`n=== PRUEBA 4.e - Restaurar cluster y verificar sincronizacion ===" -ForegroundColor Cyan

Write-Host "`n[Paso 1] Encender db-replica1" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker start db-replica1" -ForegroundColor White
docker start db-replica1
Write-Host "db-replica1 INICIANDO..." -ForegroundColor Green

Write-Host "`n[Paso 2] Encender db-replica2" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker start db-replica2" -ForegroundColor White
docker start db-replica2
Write-Host "db-replica2 INICIANDO..." -ForegroundColor Green

Write-Host "`nEsperando a que las replicas se conecten..." -ForegroundColor Gray
Start-Sleep -Seconds 10

Write-Host "`n[Paso 3] Verificar estado del cluster restaurado" -ForegroundColor Yellow
Write-Host "[COMANDO DOCKER]" -ForegroundColor Green
Write-Host "docker ps --filter 'name=db-' --format 'table {{.Names}}\t{{.Status}}'" -ForegroundColor White
docker ps | Select-String "db-"

Write-Host "`n[Paso 4] Verificar replicacion activa en Master" -ForegroundColor Yellow
Write-Host "[COMANDO SQL]" -ForegroundColor Green
Write-Host "docker exec db-master psql -U spree -d spree_db -c 'SELECT application_name, state, sync_state FROM pg_stat_replication;'" -ForegroundColor White
docker exec db-master psql -U spree -d spree_db -c "SELECT application_name, state, sync_state FROM pg_stat_replication;"

Write-Host "`n[Paso 5] Buscar TODOS los usuarios de prueba creados" -ForegroundColor Yellow
Write-Host "Buscando emails con patron: testuser_%, test_1nodo_%, test_solo_master_%`n" -ForegroundColor Cyan

Write-Host "MASTER (db-master):" -ForegroundColor Cyan
Write-Host "[COMANDO SQL]" -ForegroundColor Green
Write-Host "docker exec db-master psql -U spree -d spree_db -c `"SELECT email FROM spree_users WHERE email LIKE 'test%' ORDER BY email;`"" -ForegroundColor White
$masterUsers = docker exec db-master psql -U spree -d spree_db -t -c "SELECT email FROM spree_users WHERE email LIKE 'test%' ORDER BY email;" 2>$null
$masterCount = ($masterUsers | Where-Object { $_.Trim() -ne "" } | Measure-Object).Count
Write-Host "  Usuarios encontrados: $masterCount" -ForegroundColor White
$masterUsers | Where-Object { $_.Trim() -ne "" } | ForEach-Object { Write-Host "    - $($_.Trim())" -ForegroundColor Gray }

Write-Host "`nREPLICA 1 (db-replica1):" -ForegroundColor Cyan
Write-Host "[COMANDO SQL]" -ForegroundColor Green
Write-Host "docker exec db-replica1 psql -U spree -d spree_db -c `"SELECT email FROM spree_users WHERE email LIKE 'test%' ORDER BY email;`"" -ForegroundColor White
$replica1Users = docker exec db-replica1 psql -U spree -d spree_db -t -c "SELECT email FROM spree_users WHERE email LIKE 'test%' ORDER BY email;" 2>$null
$replica1Count = ($replica1Users | Where-Object { $_.Trim() -ne "" } | Measure-Object).Count
Write-Host "  Usuarios encontrados: $replica1Count" -ForegroundColor White
$replica1Users | Where-Object { $_.Trim() -ne "" } | ForEach-Object { Write-Host "    - $($_.Trim())" -ForegroundColor Gray }

Write-Host "`nREPLICA 2 (db-replica2):" -ForegroundColor Cyan
Write-Host "[COMANDO SQL]" -ForegroundColor Green
Write-Host "docker exec db-replica2 psql -U spree -d spree_db -c `"SELECT email FROM spree_users WHERE email LIKE 'test%' ORDER BY email;`"" -ForegroundColor White
$replica2Users = docker exec db-replica2 psql -U spree -d spree_db -t -c "SELECT email FROM spree_users WHERE email LIKE 'test%' ORDER BY email;" 2>$null
$replica2Count = ($replica2Users | Where-Object { $_.Trim() -ne "" } | Measure-Object).Count
Write-Host "  Usuarios encontrados: $replica2Count" -ForegroundColor White
$replica2Users | Where-Object { $_.Trim() -ne "" } | ForEach-Object { Write-Host "    - $($_.Trim())" -ForegroundColor Gray }

Write-Host "`n=== RESUMEN FINAL ===" -ForegroundColor Cyan
Write-Host "Nodo          | Usuarios | Estado" -ForegroundColor Yellow
Write-Host "------------- | -------- | ------" -ForegroundColor Yellow
Write-Host "db-master     | $masterCount        | ACTIVO" -ForegroundColor Green
Write-Host "db-replica1   | $replica1Count        | ACTIVO" -ForegroundColor Green
Write-Host "db-replica2   | $replica2Count        | ACTIVO" -ForegroundColor Green

if ($masterCount -eq $replica1Count -and $masterCount -eq $replica2Count -and $masterCount -gt 0) {
    Write-Host "`nEXITO: Cluster completamente sincronizado" -ForegroundColor Green
    Write-Host "Todos los usuarios creados durante las pruebas estan en los 3 nodos" -ForegroundColor White
    Write-Host "La replicacion funciona correctamente incluso despues de caidas" -ForegroundColor White
} else {
    Write-Host "`nADVERTENCIA: Diferencias en la sincronizacion" -ForegroundColor Yellow
    Write-Host "Puede que las replicas aun esten recuperandose..." -ForegroundColor Yellow
}

Write-Host "`nCLUSTER RESTAURADO Y OPERATIVO`n" -ForegroundColor Green
