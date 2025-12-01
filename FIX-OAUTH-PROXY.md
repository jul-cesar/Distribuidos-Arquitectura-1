# 🔧 Fix Aplicado: Proxy Nginx para OAuth

## 📋 Problema Identificado

El frontend intentaba hacer login a `http://localhost:3000/spree_oauth/token`, pero ese endpoint no existía en el frontend load balancer. Las peticiones OAuth necesitaban ser proxeadas al backend (puerto 4000).

## ✅ Solución Implementada

### Cambio en `load-balancers/frontend-nginx.conf`

Se agregó una nueva regla de proxy para redirigir las peticiones OAuth al backend:

```nginx
# Proxy a OAuth endpoint (backend)
location /spree_oauth/ {
  proxy_pass http://backend-lb/spree_oauth/;
  
  # Headers
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
  proxy_set_header Content-Type application/json;
  
  # Timeouts
  proxy_connect_timeout 60s;
  proxy_send_timeout 60s;
  proxy_read_timeout 60s;
}
```

### Flujo Antes del Fix ❌

```
Browser → http://localhost:3000/spree_oauth/token
         ↓
    Frontend LB (puerto 3000)
         ↓
    ❌ 404 Not Found (no existe en frontend)
```

### Flujo Después del Fix ✅

```
Browser → http://localhost:3000/spree_oauth/token
         ↓
    Frontend LB (puerto 3000)
         ↓ (proxy_pass)
    Backend LB (puerto 4000) → /spree_oauth/token
         ↓
    Spree Backend
         ↓
    ✅ 200 OK + access_token
```

## 🧪 Verificación

### Test realizado con PowerShell:

```powershell
POST http://localhost:3000/spree_oauth/token
Body: {
  "grant_type": "password",
  "username": "admin@example.com",
  "password": "spree123",
  ...
}

Response:
✅ Status: 200
✅ Token: J7iKS2OuHNSkjApwIeLu...
✅ Expira en: 30.4 días
```

### Test desde el navegador:

1. Usuario abre `http://localhost:3000/login.html`
2. Ingresa email y password
3. JavaScript hace POST a `/spree_oauth/token`
4. Nginx proxy redirige al backend
5. Backend valida y devuelve token
6. Token se guarda en localStorage
7. Redirige a `/admin.html`
8. ✅ **Login exitoso**

## 📊 Rutas Configuradas en Frontend LB

| Ruta | Destino | Propósito |
|------|---------|-----------|
| `/` | `frontend-1/2/3:80` | HTML estático |
| `/api/*` | `backend-lb:4000/api/*` | API REST de Spree |
| `/spree_oauth/*` | `backend-lb:4000/spree_oauth/*` | ✅ Autenticación OAuth |

## 🚀 Comandos Aplicados

```bash
# 1. Editar frontend-nginx.conf (agregar location /spree_oauth/)
# 2. Reiniciar frontend load balancer
docker restart frontend-lb

# 3. Verificar funcionamiento
curl -X POST http://localhost:3000/spree_oauth/token \
  -H "Content-Type: application/json" \
  -d '{...}'
```

## ✅ Estado Final

- ✅ Frontend LB proxea correctamente OAuth al backend
- ✅ Login con usuario y contraseña funcional
- ✅ Token se almacena en localStorage
- ✅ Panel de administración accesible
- ✅ CRUD de productos operativo

## 📝 Logs de Confirmación

```
docker logs frontend-lb --tail 5

172.19.0.1 - POST /spree_oauth/token HTTP/1.1 200 205
172.19.0.1 - GET /admin.html HTTP/1.1 200 5750
172.19.0.1 - GET /api/v2/storefront/products HTTP/1.1 304
```

✅ **Todo funcionando correctamente**

---

**Fecha**: Diciembre 1, 2025  
**Archivo modificado**: `load-balancers/frontend-nginx.conf`  
**Contenedor reiniciado**: `frontend-lb`
