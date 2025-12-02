Write-Host "`n=== PRUEBA 2.d - Configuracion DNS (Preguntas del docente) ===" -ForegroundColor Cyan

Write-Host "`nRESPUESTAS TECNICAS:" -ForegroundColor Yellow

Write-Host "`n[1] Donde esta configurado el DNS?" -ForegroundColor Cyan
Write-Host "Respuesta:" -ForegroundColor White
Write-Host "- Contenedor: dns-server (CoreDNS)" -ForegroundColor Gray
Write-Host "- Archivo config: dns/Corefile" -ForegroundColor Gray
Write-Host "- Puerto expuesto: 53 (UDP/TCP)" -ForegroundColor Gray
Write-Host "- Red: dmz_net + puerto mapeado al host" -ForegroundColor Gray

Write-Host "`n[Comando] Mostrar configuracion del DNS:"
Write-Host "cat dns/Corefile" -ForegroundColor Yellow
Get-Content c:\Dev\DISTRIBUIDOS-ARQ1\dns\Corefile 2>$null

Write-Host "`n[2] Que dominios resuelve el DNS?" -ForegroundColor Cyan
Write-Host "Respuesta:" -ForegroundColor White
Write-Host "- proyectosd.com (y subdominio www.proyectosd.com)" -ForegroundColor Gray
Write-Host "- Apunta a: 192.168.1.66 (IP del servidor Windows)" -ForegroundColor Gray

Write-Host "`n[3] Como funciona la resolucion?" -ForegroundColor Cyan
Write-Host "Respuesta:" -ForegroundColor White
Write-Host "1. Cliente hace query DNS: www.proyectosd.com" -ForegroundColor Gray
Write-Host "2. DNS server (puerto 53) recibe la consulta" -ForegroundColor Gray
Write-Host "3. CoreDNS busca en su configuracion (Corefile)" -ForegroundColor Gray
Write-Host "4. Retorna A record: 192.168.1.66" -ForegroundColor Gray
Write-Host "5. Cliente conecta a esa IP en puerto 3000/4000" -ForegroundColor Gray

Write-Host "`n[4] Por que usar DNS personalizado?" -ForegroundColor Cyan
Write-Host "Respuesta:" -ForegroundColor White
Write-Host "- Simula entorno productivo con dominio propio" -ForegroundColor Gray
Write-Host "- No depende de DNS publico" -ForegroundColor Gray
Write-Host "- Facil cambiar IP sin modificar clientes" -ForegroundColor Gray
Write-Host "- Permite subdominios (api.proyectosd.com, admin.proyectosd.com)" -ForegroundColor Gray

Write-Host "`n[5] Comandos utiles para verificar DNS:" -ForegroundColor Cyan
Write-Host "nslookup www.proyectosd.com localhost" -ForegroundColor Gray
Write-Host "nslookup proyectosd.com 192.168.1.66" -ForegroundColor Gray
Write-Host "docker logs dns-server" -ForegroundColor Gray
Write-Host "docker exec dns-server cat /etc/coredns/Corefile`n" -ForegroundColor Gray
