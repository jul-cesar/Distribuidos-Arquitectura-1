Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "   PLAN DE PRUEBA - PUNTO 2: DNS" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

Write-Host "`nEscoge una prueba:"
Write-Host "[1] 2.a - DNS desde servidor (localhost)"
Write-Host "[2] 2.b - DNS desde cliente Ubuntu"
Write-Host "[3] 2.c - Acceso via navegador con DNS"
Write-Host "[4] 2.d - Configuracion DNS (preguntas)"
Write-Host "[5] Ejecutar TODAS las pruebas"
Write-Host "[0] Salir"

$opcion = Read-Host "`nOpcion"

switch ($opcion) {
    "1" { & ".\2a-dns-localhost.ps1" }
    "2" { & ".\2b-dns-cliente.ps1" }
    "3" { & ".\2c-dns-navegador.ps1" }
    "4" { & ".\2d-configuracion-dns.ps1" }
    "5" {
        & ".\2a-dns-localhost.ps1"
        & ".\2b-dns-cliente.ps1"
        & ".\2c-dns-navegador.ps1"
        & ".\2d-configuracion-dns.ps1"
    }
    "0" { Write-Host "Saliendo..." -ForegroundColor Yellow }
    default { Write-Host "Opcion invalida" -ForegroundColor Red }
}
