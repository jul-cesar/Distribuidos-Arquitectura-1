Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "   PLAN DE PRUEBA - PUNTO 4: REPLICACION DB" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

Write-Host "`nEscoge una prueba:"
Write-Host "[1] 4.a - Explicar tecnologia de clusterizacion"
Write-Host "[2] 4.b - Validar sincronizacion (3 nodos activos)"
Write-Host "[3] 4.c - Desmontar replica1 y probar (2 nodos)"
Write-Host "[4] 4.d - Desmontar replica2 y probar (solo Master)"
Write-Host "[5] 4.e - Restaurar cluster completo"
Write-Host "[6] Ejecutar TODAS las pruebas (a -> b -> c -> d -> e)"
Write-Host "[0] Salir"

$opcion = Read-Host "`nOpcion"

switch ($opcion) {
    "1" { & ".\4a-tecnologia-cluster.ps1" }
    "2" { & ".\4b-sincronizacion-3nodos.ps1" }
    "3" { 
        Write-Host "`nADVERTENCIA: Esta prueba detendra db-replica1" -ForegroundColor Yellow
        $confirm = Read-Host "Continuar? (s/n)"
        if ($confirm -eq "s") {
            & ".\4c-sincronizacion-2nodos.ps1"
        }
    }
    "4" { 
        Write-Host "`nADVERTENCIA: Esta prueba detendra db-replica2 (solo quedara Master)" -ForegroundColor Yellow
        $confirm = Read-Host "Continuar? (s/n)"
        if ($confirm -eq "s") {
            & ".\4d-sincronizacion-1nodo.ps1"
        }
    }
    "5" { & ".\4e-restaurar-cluster.ps1" }
    "6" {
        Write-Host "`nEjecutando secuencia completa de pruebas..." -ForegroundColor Cyan
        & ".\4a-tecnologia-cluster.ps1"
        Write-Host "`nPresiona Enter para continuar..." -ForegroundColor Yellow
        Read-Host
        & ".\4b-sincronizacion-3nodos.ps1"
        Write-Host "`nPresiona Enter para desmontar replica1..." -ForegroundColor Yellow
        Read-Host
        & ".\4c-sincronizacion-2nodos.ps1"
        Write-Host "`nPresiona Enter para desmontar replica2..." -ForegroundColor Yellow
        Read-Host
        & ".\4d-sincronizacion-1nodo.ps1"
        Write-Host "`nPresiona Enter para restaurar cluster..." -ForegroundColor Yellow
        Read-Host
        & ".\4e-restaurar-cluster.ps1"
    }
    "0" { Write-Host "Saliendo..." -ForegroundColor Yellow }
    default { Write-Host "Opcion invalida" -ForegroundColor Red }
}
