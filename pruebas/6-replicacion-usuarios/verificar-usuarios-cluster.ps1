# Script para listar TODOS los usuarios en cada nodo del cluster
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "  USUARIOS EN TODOS LOS NODOS DEL CLUSTER" -ForegroundColor Cyan
Write-Host "==================================================`n" -ForegroundColor Cyan

# Función para listar usuarios de un nodo
function Listar-Usuarios {
    param($nombreNodo)
    
    Write-Host "`n--- $nombreNodo ---" -ForegroundColor Magenta
    
    $query = "SELECT id, email, created_at FROM spree_users ORDER BY id;"
    
    $resultado = docker exec $nombreNodo psql -U spree -d spree_db -c "$query" 2>$null
    
    Write-Host $resultado
}

# Listar usuarios de cada nodo
Listar-Usuarios "db-master"
Listar-Usuarios "db-replica1"  
Listar-Usuarios "db-replica2"

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "Si los 3 nodos tienen los mismos usuarios," -ForegroundColor Green
Write-Host "la replicacion esta funcionando correctamente" -ForegroundColor Green
Write-Host "==================================================`n" -ForegroundColor Cyan
