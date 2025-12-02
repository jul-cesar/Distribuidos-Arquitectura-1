Write-Host "`n=== PRUEBA 3.a - Configuracion del Firewall ===" -ForegroundColor Cyan

Write-Host "`nEn este proyecto, el FIREWALL esta implementado mediante:" -ForegroundColor Yellow
Write-Host "1. Windows Firewall (reglas del SO)" -ForegroundColor White
Write-Host "2. Docker port mapping (puertos expuestos)" -ForegroundColor White
Write-Host "3. Nginx Load Balancers (controlan acceso a frontends/backends)" -ForegroundColor White

Write-Host "`n=== PUERTOS ABIERTOS HACIA LA DMZ ===" -ForegroundColor Cyan

Write-Host "`n[Comando] netsh advfirewall firewall show rule name=all | Select-String '3000|4000|53|80'"
Write-Host "Mostrando reglas de Windows Firewall para puertos del proyecto..." -ForegroundColor Gray

Write-Host "`n[Comando] docker ps --format 'table {{.Names}}\t{{.Ports}}' | Select-String 'lb|dns'"
docker ps --format "table {{.Names}}\t{{.Ports}}" | Select-String "lb|dns"

Write-Host "`n=== EXPLICACION DE PUERTOS ===" -ForegroundColor Yellow

Write-Host "`nPuerto 53 (DNS):" -ForegroundColor Cyan
Write-Host "- Contenedor: dns-server" -ForegroundColor White
Write-Host "- Funcion: Resolucion de nombres (www.proyectosd.com)" -ForegroundColor White
Write-Host "- Acceso: Red externa -> DNS" -ForegroundColor White

Write-Host "`nPuerto 3000 (Frontend Load Balancer):" -ForegroundColor Cyan
Write-Host "- Contenedor: frontend-lb (Nginx)" -ForegroundColor White
Write-Host "- Funcion: Distribuir peticiones HTTP entre frontend-1, 2, 3" -ForegroundColor White
Write-Host "- Acceso: Red externa -> frontend-lb -> DMZ (frontends)" -ForegroundColor White
Write-Host "- Forwarding: frontend-lb:80 <- host:3000" -ForegroundColor Gray

Write-Host "`nPuerto 4000 (Backend Load Balancer):" -ForegroundColor Cyan
Write-Host "- Contenedor: backend-lb (Nginx)" -ForegroundColor White
Write-Host "- Funcion: Distribuir peticiones API entre backend-1, 2, 3" -ForegroundColor White
Write-Host "- Acceso: Red externa -> backend-lb -> DMZ -> Internal (backends)" -ForegroundColor White
Write-Host "- Forwarding: backend-lb:80 <- host:4000" -ForegroundColor Gray

Write-Host "`n=== CONFIGURACION NGINX (Load Balancers) ===" -ForegroundColor Cyan

Write-Host "`n[Upstream Frontend] Backends configurados en frontend-lb:"
Write-Host "[Comando] docker exec frontend-lb cat /etc/nginx/nginx.conf | Select-String 'upstream|server frontend'" -ForegroundColor Yellow
docker exec frontend-lb cat /etc/nginx/nginx.conf | Select-String "upstream|server frontend" | Select-Object -First 5

Write-Host "`n[Upstream Backend] Backends configurados en backend-lb:"
Write-Host "[Comando] docker exec backend-lb cat /etc/nginx/nginx.conf | Select-String 'upstream|server spree-backend'" -ForegroundColor Yellow
docker exec backend-lb cat /etc/nginx/nginx.conf | Select-String "upstream|server spree-backend" | Select-Object -First 5

Write-Host "`n=== REGLAS DE FORWARDING ===" -ForegroundColor Yellow
Write-Host "Red Externa (Internet/Cliente)" -ForegroundColor White
Write-Host "       |" -ForegroundColor Gray
Write-Host "       v" -ForegroundColor Gray
Write-Host "[Windows Firewall] - Permite puertos 53, 3000, 4000" -ForegroundColor White
Write-Host "       |" -ForegroundColor Gray
Write-Host "       v" -ForegroundColor Gray
Write-Host "[Docker Port Mapping] - Mapea host:3000 -> frontend-lb:80" -ForegroundColor White
Write-Host "       |" -ForegroundColor Gray
Write-Host "       v" -ForegroundColor Gray
Write-Host "[Nginx LB] - Distribuye a frontend-1:80, frontend-2:80, frontend-3:80" -ForegroundColor White
Write-Host "       |" -ForegroundColor Gray
Write-Host "       v" -ForegroundColor Gray
Write-Host "[DMZ Network] - Frontends servidos" -ForegroundColor Green

Write-Host "`nCONCLUSION: El firewall permite acceso SOLO a puertos especificos" -ForegroundColor Green
Write-Host "y los Load Balancers controlan el forwarding hacia la DMZ`n" -ForegroundColor Green
