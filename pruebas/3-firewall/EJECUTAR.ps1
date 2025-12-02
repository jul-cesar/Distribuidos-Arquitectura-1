Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   PLAN DE PRUEBA - PUNTO 3: FIREWALL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nEscoge una prueba:"
Write-Host "[1] 3.a - Mostrar configuracion del Firewall"
Write-Host "[2] 3.b - Cerrar puerto 3000 y probar bloqueo"
Write-Host "[3] 3.c - Abrir puerto 3000 y verificar acceso"
Write-Host "[4] Ejecutar TODAS las pruebas (a -> b -> c)"
Write-Host "[0] Salir"

$opcion = Read-Host "`nOpcion"

switch ($opcion) {
    "1" { & ".\3a-configuracion-firewall.ps1" }
    "2" { 
        Write-Host "`nADVERTENCIA: Esta prueba detendra frontend-lb" -ForegroundColor Yellow
        $confirm = Read-Host "Continuar? (s/n)"
        if ($confirm -eq "s") {
            & ".\3b-cerrar-puerto.ps1"
        }
    }
    "3" { & ".\3c-abrir-puerto.ps1" }
    "4" {
        & ".\3a-configuracion-firewall.ps1"
        Write-Host "`nPresiona Enter para continuar con la prueba de cierre..." -ForegroundColor Yellow
        Read-Host
        & ".\3b-cerrar-puerto.ps1"
        Write-Host "`nPresiona Enter para reabrir el puerto..." -ForegroundColor Yellow
        Read-Host
        & ".\3c-abrir-puerto.ps1"
    }
    "0" { Write-Host "Saliendo..." -ForegroundColor Yellow }
    default { Write-Host "Opcion invalida" -ForegroundColor Red }
}
