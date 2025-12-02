Write-Host "`n=== PRUEBA 2.b - DNS desde cliente Ubuntu ===" -ForegroundColor Cyan

Write-Host "`nEsta prueba se ejecuta DESDE LA MAQUINA CLIENTE (Ubuntu VM)" -ForegroundColor Yellow
Write-Host "`n[Comando para ejecutar en Ubuntu VM]:" -ForegroundColor Cyan
Write-Host "nslookup www.proyectosd.com 192.168.1.66" -ForegroundColor White

Write-Host "`nPASOS:" -ForegroundColor Yellow
Write-Host "1. Conectarse a la VM Ubuntu (cliente)" -ForegroundColor White
Write-Host "2. Ejecutar: nslookup www.proyectosd.com 192.168.1.66" -ForegroundColor White
Write-Host "3. Deberia retornar: Address: 192.168.1.66" -ForegroundColor White

Write-Host "`nRESULTADO ESPERADO:" -ForegroundColor Cyan
Write-Host "Server:     192.168.1.66" -ForegroundColor Gray
Write-Host "Address:    192.168.1.66#53" -ForegroundColor Gray
Write-Host "" -ForegroundColor Gray
Write-Host "Name:       www.proyectosd.com" -ForegroundColor Gray
Write-Host "Address:    192.168.1.66" -ForegroundColor Gray

Write-Host "`nEXPLICACION:" -ForegroundColor Cyan
Write-Host "- Cliente pregunta al DNS (192.168.1.66:53)" -ForegroundColor White
Write-Host "- DNS retorna la IP del servidor donde estan los load balancers" -ForegroundColor White
Write-Host "- Esto permite al cliente acceder a la aplicacion via nombre de dominio`n" -ForegroundColor White
