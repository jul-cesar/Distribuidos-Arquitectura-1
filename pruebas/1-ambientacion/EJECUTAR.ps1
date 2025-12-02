Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "   PLAN DE PRUEBA - AMBIENTACION" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

Write-Host "`nEscoge una prueba:"
Write-Host "[1] 1.a - Mostrar maquinas"
Write-Host "[2] 1.b - Arquitectura del proyecto"
Write-Host "[3] 1.c - Verificar despliegue"
Write-Host "[4] 1.d - Verificar redes"
Write-Host "[5] Ejecutar TODAS las pruebas"
Write-Host "[0] Salir"

$opcion = Read-Host "`nOpcion"

switch ($opcion) {
    "1" { & ".\1a-maquinas.ps1" }
    "2" { & ".\1b-arquitectura.ps1" }
    "3" { & ".\1c-verificar-despliegue.ps1" }
    "4" { & ".\1d-verificar-redes.ps1" }
    "5" {
        & ".\1a-maquinas.ps1"
        & ".\1b-arquitectura.ps1"
        & ".\1c-verificar-despliegue.ps1"
        & ".\1d-verificar-redes.ps1"
    }
    "0" { Write-Host "Saliendo..." -ForegroundColor Yellow }
    default { Write-Host "Opcion invalida" -ForegroundColor Red }
}
