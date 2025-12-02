Write-Host "`n=== PRUEBA 4.a - Tecnologia de Clusterizacion ===" -ForegroundColor Cyan

Write-Host "`n=== TECNOLOGIA UTILIZADA ===" -ForegroundColor Yellow
Write-Host "PostgreSQL 14 con Streaming Replication (Master-Replica)" -ForegroundColor White

Write-Host "`n=== ARQUITECTURA DEL CLUSTER ===" -ForegroundColor Cyan
Write-Host "1 Nodo Master (Lectura/Escritura)" -ForegroundColor White
Write-Host "  - Contenedor: db-master" -ForegroundColor Gray
Write-Host "  - Funcion: Procesa todas las escrituras" -ForegroundColor Gray
Write-Host "  - Puerto: 5432" -ForegroundColor Gray

Write-Host "`n2 Nodos Replica (Solo Lectura)" -ForegroundColor White
Write-Host "  - Contenedores: db-replica1, db-replica2" -ForegroundColor Gray
Write-Host "  - Funcion: Copias sincronizadas del master" -ForegroundColor Gray
Write-Host "  - Puertos: 5432" -ForegroundColor Gray

Write-Host "`n=== COMO FUNCIONA LA REPLICACION ===" -ForegroundColor Yellow

Write-Host "`nStreaming Replication:" -ForegroundColor Cyan
Write-Host "1. Backend escribe en db-master" -ForegroundColor White
Write-Host "2. Master registra cambios en WAL (Write-Ahead Log)" -ForegroundColor White
Write-Host "3. Replicas se conectan via streaming" -ForegroundColor White
Write-Host "4. Master envia WAL a replicas en tiempo real" -ForegroundColor White
Write-Host "5. Replicas aplican cambios automaticamente" -ForegroundColor White

Write-Host "`n=== VERIFICAR CLUSTER ===" -ForegroundColor Cyan

Write-Host "`n[Comando] docker ps | Select-String 'db-'"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | Select-String "db-"

Write-Host "`n[Comando] Verificar replicacion activa en master"
Write-Host "docker exec db-master psql -U spree -d spree_db -c 'SELECT * FROM pg_stat_replication;'" -ForegroundColor Yellow
docker exec db-master psql -U spree -d spree_db -c "SELECT application_name, client_addr, state, sync_state FROM pg_stat_replication;"

Write-Host "`n[Comando] Verificar que replicas estan en modo recovery"
Write-Host "docker exec db-replica1 psql -U spree -d spree_db -c 'SELECT pg_is_in_recovery();'" -ForegroundColor Yellow
$replica1 = docker exec db-replica1 psql -U spree -d spree_db -t -c "SELECT pg_is_in_recovery();" 2>$null
$replica2 = docker exec db-replica2 psql -U spree -d spree_db -t -c "SELECT pg_is_in_recovery();" 2>$null

if ($replica1 -match "t") {
    Write-Host "db-replica1: En modo RECOVERY (replica activa)" -ForegroundColor Green
} else {
    Write-Host "db-replica1: NO esta en modo recovery" -ForegroundColor Red
}

if ($replica2 -match "t") {
    Write-Host "db-replica2: En modo RECOVERY (replica activa)" -ForegroundColor Green
} else {
    Write-Host "db-replica2: NO esta en modo recovery" -ForegroundColor Red
}

Write-Host "`n=== BALANCEO DE CARGA ===" -ForegroundColor Yellow
Write-Host "ESCRITURAS: Siempre van al MASTER" -ForegroundColor White
Write-Host "  - Backend usa DATABASE_URL apuntando a db-master:5432" -ForegroundColor Gray

Write-Host "`nLECTURAS: Pueden distribuirse entre master y replicas" -ForegroundColor White
Write-Host "  - Actualmente: Backend lee solo del master" -ForegroundColor Gray
Write-Host "  - Potencial: Configurar read replicas para consultas pesadas" -ForegroundColor Gray

Write-Host "`n=== VENTAJAS DE ESTA ARQUITECTURA ===" -ForegroundColor Cyan
Write-Host "1. Alta disponibilidad: Si master cae, replica puede promover" -ForegroundColor White
Write-Host "2. Backup en tiempo real: Replicas son copias exactas" -ForegroundColor White
Write-Host "3. Escalabilidad: Agregar mas replicas para lecturas" -ForegroundColor White
Write-Host "4. Sin perdida de datos: Replicacion sincrona disponible`n" -ForegroundColor White
