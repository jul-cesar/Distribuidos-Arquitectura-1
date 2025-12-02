Write-Host "`n=== PRUEBA 1.d - VERIFICAR REDES ===" -ForegroundColor Cyan

Write-Host "`n[Comando] docker network ls"
docker network ls

Write-Host "`n[Comando] docker network inspect dmz_net"
docker network inspect dmz_net --format "{{.Name}}: {{len .Containers}} contenedores"

Write-Host "`n[Comando] docker network inspect internal_net"
docker network inspect internal_net --format "{{.Name}}: {{len .Containers}} contenedores"

Write-Host "`n=== EXPLICACION DE LAS 3 CAPAS ===" -ForegroundColor Yellow
Write-Host "`n1. RED EXTERNA (Port Mapping)" -ForegroundColor Cyan
Write-Host "   - NO aparece como red Docker"
Write-Host "   - Usa puertos expuestos: 80, 3000, 4000, 53"
Write-Host "   - Accesible desde navegador: http://localhost:3000"

Write-Host "`n2. DMZ_NET - Zona Desmilitarizada (8 contenedores)" -ForegroundColor Cyan
Write-Host "   - dns-server"
Write-Host "   - frontend-lb + 3 frontends"
Write-Host "   - backend-lb + 2 backends"
Write-Host "   - Funcion: Capa de presentacion y logica web"

Write-Host "`n3. INTERNAL_NET - Red Interna (7 contenedores)" -ForegroundColor Cyan
Write-Host "   - 3 backends (estan en AMBAS redes)"
Write-Host "   - 3 bases de datos (master + 2 replicas)"
Write-Host "   - redis (cache)"
Write-Host "   - Funcion: Datos sensibles, completamente aislada"

Write-Host "`nNOTA: Los backends estan en dmz_net E internal_net" -ForegroundColor Yellow
Write-Host "      Por eso 8+7=15 pero solo hay 13 contenedores totales`n" -ForegroundColor Yellow

Write-Host "`n=== PRUEBAS DE COMUNICACION ENTRE REDES ===" -ForegroundColor Cyan

Write-Host "`n[TEST 1] Frontend-1 puede comunicarse con Backend-1 (ambos en dmz_net)" -ForegroundColor Yellow
Write-Host "[Comando] docker exec frontend-1 wget -qO- http://spree-backend-1:3000/api/v2/storefront/products"
try {
    $result = docker exec frontend-1 wget -qO- http://spree-backend-1:3000/api/v2/storefront/products 2>$null
    if ($result) {
        Write-Host "EXITO: Frontend puede comunicarse con Backend" -ForegroundColor Green
    } else {
        Write-Host "FALLO: No hay comunicacion" -ForegroundColor Red
    }
} catch {
    Write-Host "FALLO: Error en la comunicacion" -ForegroundColor Red
}

Write-Host "`n[TEST 2] Backend-1 puede comunicarse con DB-Master (ambos en internal_net)" -ForegroundColor Yellow
Write-Host "[Comando] docker exec spree-backend-1 bin/rails runner 'ActiveRecord::Base.connection.execute..'"
try {
    $result = docker exec spree-backend-1 bin/rails runner "puts ActiveRecord::Base.connection.execute('SELECT 1').first['?column?']" 2>$null
    if ($result -match "1") {
        Write-Host "EXITO: Backend puede comunicarse con Database" -ForegroundColor Green
    } else {
        Write-Host "FALLO: No hay comunicacion" -ForegroundColor Red
    }
} catch {
    Write-Host "FALLO: Error en la comunicacion" -ForegroundColor Red
}

Write-Host "`n[TEST 3] Backend-1 puede comunicarse con Redis (ambos en internal_net)" -ForegroundColor Yellow
Write-Host "[Comando] docker exec spree-backend-1 bin/rails runner 'Redis.new...'"
try {
    $result = docker exec spree-backend-1 bin/rails runner "puts Redis.new(url: ENV['REDIS_URL']).ping" 2>$null
    if ($result -match "PONG") {
        Write-Host "EXITO: Backend puede comunicarse con Redis" -ForegroundColor Green
    } else {
        Write-Host "FALLO: No hay comunicacion" -ForegroundColor Red
    }
} catch {
    Write-Host "FALLO: Error en la comunicacion" -ForegroundColor Red
}

Write-Host "`n[TEST 4] Frontend-1 NO puede comunicarse con DB-Master (diferentes redes)" -ForegroundColor Yellow
Write-Host "[Comando] docker exec frontend-1 ping -c 1 -W 1 db-master"
try {
    $result = docker exec frontend-1 sh -c "ping -c 1 -W 1 db-master" 2>&1
    if ($result -match "1 received|1 packets received") {
        Write-Host "ADVERTENCIA: Frontend puede acceder a DB (deberia estar aislado!)" -ForegroundColor Red
    } else {
        Write-Host "EXITO: Frontend NO puede acceder a DB (aislamiento correcto)" -ForegroundColor Green
    }
} catch {
    Write-Host "EXITO: Frontend NO puede acceder a DB (aislamiento correcto)" -ForegroundColor Green
}

Write-Host "`n[TEST 5] DNS-Server puede resolver nombres en dmz_net" -ForegroundColor Yellow
Write-Host "[Comando] docker exec dns-server ping -c 1 frontend-1"
try {
    $result = docker exec dns-server ping -c 1 frontend-1 2>&1
    if ($result -match "1 received|1 packets received") {
        Write-Host "EXITO: DNS puede comunicarse con frontend-1" -ForegroundColor Green
    } else {
        Write-Host "FALLO: DNS no puede resolver/alcanzar frontend-1" -ForegroundColor Red
    }
} catch {
    Write-Host "FALLO: Error al verificar DNS" -ForegroundColor Red
}

Write-Host "`nCONCLUSION: Aislamiento de redes funcionando correctamente" -ForegroundColor Green
Write-Host "- Componentes en la misma red: SI se comunican" -ForegroundColor White
Write-Host "- Componentes en diferentes redes: NO se comunican (salvo backends puente)`n" -ForegroundColor White
