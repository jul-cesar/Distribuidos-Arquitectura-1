# PUNTO 6: REPLICACION DE USUARIOS EN CLUSTER DE BASE DE DATOS
Write-Host "`n===============================================================" -ForegroundColor Magenta
Write-Host "     PUNTO 6: REPLICACION DE USUARIOS EN CLUSTER" -ForegroundColor Magenta
Write-Host "===============================================================`n" -ForegroundColor Magenta
Write-Host "Objetivo: Demostrar que un usuario registrado en el frontend" -ForegroundColor Cyan
Write-Host "          se replica en todos los nodos del cluster de BD`n" -ForegroundColor Cyan
if (!(Test-Path ".\pruebas\6-replicacion-usuarios\6a-registrar-y-verificar-usuario.ps1")) {
    Write-Host "Error: Este script debe ejecutarse desde el directorio raiz" -ForegroundColor Red
    exit 1
}
Write-Host "VERIFICANDO SERVICIOS`n" -ForegroundColor Yellow
$servicios = @("db-master", "db-replica1", "db-replica2", "frontend-lb")
$todosOk = $true
foreach ($servicio in $servicios) {
    $estado = docker ps --filter "name=$servicio" --format "{{.Status}}" 2>$null
    if ($estado -match "Up") {
        Write-Host "$servicio - OK" -ForegroundColor Green
    } else {
        Write-Host "$servicio - FALLO" -ForegroundColor Red
        $todosOk = $false
    }
}
if (!$todosOk) {
    Write-Host "`nError: Servicios no disponibles`n" -ForegroundColor Red
    exit 1
}
Write-Host "`nEjecutando prueba...`n" -ForegroundColor Cyan
& ".\pruebas\6-replicacion-usuarios\6a-registrar-y-verificar-usuario.ps1"
Write-Host "`nPUNTO 6 COMPLETADO`n" -ForegroundColor Magenta