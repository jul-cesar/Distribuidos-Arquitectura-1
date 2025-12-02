Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  PRUEBAS - PUNTO 5: BALANCEADOR DE CARGA" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "OBJETIVO: Demostrar funcionamiento del Load Balancer" -ForegroundColor Yellow
Write-Host "- Identificar Nginx y algoritmo Round Robin" -ForegroundColor White
Write-Host "- Distribucion de trafico entre 3 nodos" -ForegroundColor White
Write-Host "- Tolerancia a fallos (1, 2 nodos caidos)" -ForegroundColor White
Write-Host "- Sistema no disponible sin nodos" -ForegroundColor White

Write-Host "`nSCRIPTS DISPONIBLES:" -ForegroundColor Yellow
Write-Host "1. Identificar balanceador y algoritmo (5a)" -ForegroundColor White
Write-Host "2. Distribucion entre 3 nodos (5b)" -ForegroundColor White
Write-Host "3. Desmontar 1 nodo, 2 activos (5c)" -ForegroundColor White
Write-Host "4. Desmontar 2do nodo, 1 activo (5d)" -ForegroundColor White
Write-Host "5. Desmontar ultimo nodo + restaurar (5e)" -ForegroundColor White
Write-Host "6. Ejecutar prueba completa 5a->5b->5c->5d->5e" -ForegroundColor Green
Write-Host "0. Salir" -ForegroundColor Gray

$opcion = Read-Host "`nSelecciona una opcion"

switch ($opcion) {
    "1" {
        Write-Host "`nEjecutando: Identificar balanceador..." -ForegroundColor Green
        .\5a-identificar-balanceador.ps1
    }
    "2" {
        Write-Host "`nEjecutando: Distribucion entre 3 nodos..." -ForegroundColor Green
        .\5b-distribucion-3nodos.ps1
    }
    "3" {
        Write-Host "`nEjecutando: Desmontar 1 nodo..." -ForegroundColor Green
        Write-Host "ADVERTENCIA: Se detendra frontend-1" -ForegroundColor Yellow
        .\5c-desmontar-1nodo.ps1
    }
    "4" {
        Write-Host "`nEjecutando: Desmontar 2do nodo..." -ForegroundColor Green
        Write-Host "ADVERTENCIA: Se detendra frontend-2" -ForegroundColor Yellow
        .\5d-desmontar-2nodos.ps1
    }
    "5" {
        Write-Host "`nEjecutando: Desmontar ultimo nodo..." -ForegroundColor Green
        Write-Host "ADVERTENCIA: Sistema quedara NO DISPONIBLE temporalmente" -ForegroundColor Red
        .\5e-desmontar-todos.ps1
    }
    "6" {
        Write-Host "`nEjecutando: PRUEBA COMPLETA..." -ForegroundColor Green
        Write-Host "Esta prueba ejecutara todos los scripts en secuencia" -ForegroundColor Yellow
        Write-Host "Presiona Enter para continuar o Ctrl+C para cancelar..." -ForegroundColor Yellow
        Read-Host
        
        Write-Host "`n=== SCRIPT 5a: Identificar balanceador ===" -ForegroundColor Magenta
        .\5a-identificar-balanceador.ps1
        Write-Host "`nPresiona Enter para continuar..." -ForegroundColor Yellow
        Read-Host
        
        Write-Host "`n=== SCRIPT 5b: Distribucion 3 nodos ===" -ForegroundColor Magenta
        .\5b-distribucion-3nodos.ps1
        Write-Host "`nPresiona Enter para continuar..." -ForegroundColor Yellow
        Read-Host
        
        Write-Host "`n=== SCRIPT 5c: Desmontar 1 nodo ===" -ForegroundColor Magenta
        .\5c-desmontar-1nodo.ps1
        Write-Host "`nPresiona Enter para continuar..." -ForegroundColor Yellow
        Read-Host
        
        Write-Host "`n=== SCRIPT 5d: Desmontar 2do nodo ===" -ForegroundColor Magenta
        .\5d-desmontar-2nodos.ps1
        Write-Host "`nPresiona Enter para continuar..." -ForegroundColor Yellow
        Read-Host
        
        Write-Host "`n=== SCRIPT 5e: Desmontar ultimo + restaurar ===" -ForegroundColor Magenta
        .\5e-desmontar-todos.ps1
        
        Write-Host "`n========================================" -ForegroundColor Green
        Write-Host "  PRUEBA COMPLETA FINALIZADA" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
    }
    "0" {
        Write-Host "`nSaliendo..." -ForegroundColor Gray
        exit
    }
    default {
        Write-Host "`nOpcion no valida" -ForegroundColor Red
    }
}

Write-Host ""
