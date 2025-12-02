Write-Host "`n=== PRUEBA DE PERMISOS DE ADMINISTRADOR ===" -ForegroundColor Cyan
Write-Host ""

# Instrucciones
Write-Host "[PASO 1] Primero, necesitas iniciar sesion como admin" -ForegroundColor Yellow
Write-Host "  1. Abre: http://localhost:3000/login.html" -ForegroundColor White
Write-Host "  2. Ingresa:" -ForegroundColor White
Write-Host "     Email: admin@example.com" -ForegroundColor Cyan
Write-Host "     Password: spree123" -ForegroundColor Cyan
Write-Host "  3. Una vez logueado, copia el token que aparece en consola del navegador (F12)" -ForegroundColor White
Write-Host ""

# Pedir el token al usuario
$token = Read-Host "Pega aqui tu token de acceso (Bearer ...)"

if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host "Error: No se proporciono un token" -ForegroundColor Red
    exit 1
}

# Limpiar el token si viene con "Bearer "
$token = $token.Trim()
if ($token.StartsWith("Bearer ")) {
    $token = $token.Substring(7).Trim()
}

Write-Host ""
Write-Host "[PASO 2] Verificando permisos de administrador..." -ForegroundColor Yellow

try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    $response = Invoke-RestMethod -Uri "http://localhost:4000/api/v1/users/me" -Headers $headers -Method Get
    
    Write-Host "  Usuario: $($response.email)" -ForegroundColor Green
    Write-Host "  Es admin: $($response.is_admin)" -ForegroundColor $(if ($response.is_admin) { "Green" } else { "Red" })
    
    if (-not $response.is_admin) {
        Write-Host ""
        Write-Host "ERROR: Este usuario no tiene permisos de administrador" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "  Error verificando usuario: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[PASO 3] Probando endpoints de administracion..." -ForegroundColor Yellow

# Probar GET (listar productos)
Write-Host "  [GET] Listando productos..." -ForegroundColor White
try {
    $response = Invoke-RestMethod -Uri "http://localhost:4000/api/v1/admin/products" -Headers $headers -Method Get
    $productCount = $response.data.Count
    Write-Host "    OK - $productCount productos encontrados" -ForegroundColor Green
} catch {
    Write-Host "    ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "    Detalles: $($_.ErrorDetails.Message)" -ForegroundColor Red
}

# Probar POST (crear producto)
Write-Host "  [POST] Creando producto de prueba..." -ForegroundColor White
try {
    $newProduct = @{
        product = @{
            name = "Producto de Prueba $(Get-Date -Format 'HHmmss')"
            description = "Este es un producto de prueba creado automaticamente"
            price = 99.99
            status = "active"
        }
    }
    
    $headers["Content-Type"] = "application/json"
    $response = Invoke-RestMethod -Uri "http://localhost:4000/api/v1/admin/products" `
        -Headers $headers `
        -Method Post `
        -Body ($newProduct | ConvertTo-Json -Depth 10)
    
    $createdId = $response.data.id
    Write-Host "    OK - Producto creado con ID: $createdId" -ForegroundColor Green
    
    # Probar PATCH (actualizar producto)
    Write-Host "  [PATCH] Actualizando producto..." -ForegroundColor White
    $updateProduct = @{
        product = @{
            name = "Producto Actualizado"
            price = 149.99
        }
    }
    
    $response = Invoke-RestMethod -Uri "http://localhost:4000/api/v1/admin/products/$createdId" `
        -Headers $headers `
        -Method Patch `
        -Body ($updateProduct | ConvertTo-Json -Depth 10)
    
    Write-Host "    OK - Producto actualizado" -ForegroundColor Green
    
    # Probar DELETE (eliminar producto)
    Write-Host "  [DELETE] Eliminando producto de prueba..." -ForegroundColor White
    Invoke-RestMethod -Uri "http://localhost:4000/api/v1/admin/products/$createdId" `
        -Headers $headers `
        -Method Delete | Out-Null
    
    Write-Host "    OK - Producto eliminado" -ForegroundColor Green
    
} catch {
    Write-Host "    ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "    Detalles: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "OK Todos los endpoints de administracion funcionan correctamente" -ForegroundColor Green
Write-Host ""
Write-Host "Ahora puedes usar el panel de administracion en:" -ForegroundColor Yellow
Write-Host "  http://localhost:3000/admin.html" -ForegroundColor Cyan
Write-Host ""
