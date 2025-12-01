# 🔐 Autenticación OAuth2 en Spree Commerce

## 📋 Resumen Ejecutivo

Este documento explica los **dos métodos de autenticación OAuth2** implementados en el sistema:

1. ✅ **Password Grant** (Recomendado) - Login con usuario y contraseña
2. ⚙️ **Client Credentials Grant** - Para aplicaciones server-to-server

---

## 👤 Método 1: Password Grant (Usuario + Contraseña)

### ✅ **Recomendado para usuarios humanos**

Este es el método **tradicional** donde los usuarios ingresan su email y contraseña.

### 📝 Credenciales de Prueba

```
Email: admin@example.com
Password: spree123
```

### 🔄 Flujo de Autenticación

```
1. Usuario ingresa email y password en /login.html
2. Frontend hace POST a /spree_oauth/token con:
   - grant_type: "password"
   - username: email
   - password: contraseña
   - client_id: (credenciales de la app)
   - client_secret: (credenciales de la app)
3. Backend valida usuario y contraseña
4. Devuelve access_token asociado al usuario
5. Token se guarda en localStorage
6. Usuario puede acceder al panel de administración
```

### 💻 Implementación Frontend

**Login Form** (`frontend/login.html`):

```html
<form id="loginForm" onsubmit="login(event)">
  <div class="form-group">
    <label for="email">Email</label>
    <input type="email" id="email" required placeholder="admin@example.com" />
  </div>

  <div class="form-group">
    <label for="password">Contraseña</label>
    <input type="password" id="password" required placeholder="••••••••" />
  </div>

  <button type="submit" class="btn">🚀 Iniciar Sesión</button>
</form>
```

**Login Logic** (JavaScript):

```javascript
async function login(event) {
  event.preventDefault();
  
  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;

  const response = await fetch('/spree_oauth/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      grant_type: "password",
      username: email,
      password: password,
      client_id: "sDdImYdx_kqvffaOTNxYsOtX_5w1XQGkxrr9RaTLIpg",
      client_secret: "$2a$12$u7yy7JgbJuyKp25BGkskHOz7Ei1Yv3pH3KzOq72RnzhMVWaijAswy"
    })
  });

  const data = await response.json();
  
  // Guardar token
  localStorage.setItem('api_token', data.access_token);
  localStorage.setItem('api_token_expiry', Date.now() + (data.expires_in * 1000));
  
  // Redirigir al panel
  window.location.href = '/admin.html';
}
```

### 🧪 Prueba con PowerShell

```powershell
$body = @{
    grant_type = "password"
    username = "admin@example.com"
    password = "spree123"
    client_id = "sDdImYdx_kqvffaOTNxYsOtX_5w1XQGkxrr9RaTLIpg"
    client_secret = '$2a$12$u7yy7JgbJuyKp25BGkskHOz7Ei1Yv3pH3KzOq72RnzhMVWaijAswy'
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:4000/spree_oauth/token" `
                  -Method POST `
                  -ContentType "application/json" `
                  -Body $body
```

**Respuesta**:
```json
{
  "access_token": "NhDyc7tkUncEtTM4alUH3BidjM0zVciJwI4anJkRYZU",
  "token_type": "Bearer",
  "expires_in": 2629746,
  "scope": "admin",
  "created_at": 1764567617
}
```

---

## ⚙️ Método 2: Client Credentials Grant (Server-to-Server)

### 🤖 **Recomendado para aplicaciones automatizadas**

Este método es para aplicaciones que necesitan acceso sin interacción humana.

### 🔄 Flujo de Autenticación

```
1. Aplicación tiene client_id y client_secret
2. POST a /spree_oauth/token con:
   - grant_type: "client_credentials"
   - client_id: ID de la aplicación
   - client_secret: Secreto de la aplicación
3. Backend valida credenciales de la app
4. Devuelve access_token (no asociado a usuario específico)
```

### 💻 Implementación

```javascript
async function getAppToken() {
  const response = await fetch('/spree_oauth/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      grant_type: "client_credentials",
      client_id: "sDdImYdx_kqvffaOTNxYsOtX_5w1XQGkxrr9RaTLIpg",
      client_secret: "$2a$12$u7yy7JgbJuyKp25BGkskHOz7Ei1Yv3pH3KzOq72RnzhMVWaijAswy",
      scope: "admin"
    })
  });

  return await response.json();
}
```

### 🧪 Prueba con PowerShell

```powershell
$body = @{
    grant_type = "client_credentials"
    client_id = "sDdImYdx_kqvffaOTNxYsOtX_5w1XQGkxrr9RaTLIpg"
    client_secret = '$2a$12$u7yy7JgbJuyKp25BGkskHOz7Ei1Yv3pH3KzOq72RnzhMVWaijAswy'
    scope = "admin"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:4000/spree_oauth/token" `
                  -Method POST `
                  -ContentType "application/json" `
                  -Body $body
```

---

## ⚖️ Comparación de Métodos

| Característica | Password Grant | Client Credentials |
|----------------|----------------|-------------------|
| **Uso** | ✅ Usuarios humanos | ⚙️ Aplicaciones automatizadas |
| **Input** | Email + Password | Client ID + Secret |
| **Token asociado a** | Usuario específico | Aplicación |
| **Casos de uso** | Login web, mobile apps | Scripts, cron jobs, APIs |
| **Interfaz** | Formulario de login | Configuración de app |
| **Auditoría** | Por usuario | Por aplicación |
| **Ejemplo** | Admin panel, CMS | Sincronización de datos |

---

## 📊 Diagrama de Flujos

### Arquitectura de Red

```
┌─────────────────────────────────────────────────────────────────┐
│                         Usuario (Browser)                        │
│                     http://localhost:3000                        │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Frontend Load Balancer                        │
│                       (Nginx - Puerto 3000)                      │
├─────────────────────────────────────────────────────────────────┤
│  Route: /               → frontend-1/2/3 (HTML estático)        │
│  Route: /api/*          → backend-lb:4000/api/*                 │
│  Route: /spree_oauth/*  → backend-lb:4000/spree_oauth/*  ✅ FIX │
└────────────────────────────┬────────────────────────────────────┘
                             │
           ┌─────────────────┴─────────────────┐
           │                                   │
           ▼                                   ▼
┌──────────────────────┐         ┌──────────────────────┐
│  Frontend Cluster    │         │  Backend Load Balancer│
│  (3 nginx estáticos) │         │  (Nginx - Puerto 4000)│
│  - frontend-1:80     │         ├──────────────────────┤
│  - frontend-2:80     │         │  Route: /api/*       │
│  - frontend-3:80     │         │  Route: /spree_oauth/│
└──────────────────────┘         └──────────┬───────────┘
                                            │
                              ┌─────────────┴─────────────┐
                              │                           │
                              ▼                           ▼
                   ┌──────────────────┐       ┌──────────────────┐
                   │ Spree Backend    │       │  PostgreSQL      │
                   │ Cluster (3)      │       │  Master-Slave    │
                   │ - backend-1      │◄──────┤  - db-master     │
                   │ - backend-2      │       │  - db-replica1   │
                   │ - backend-3      │       │  - db-replica2   │
                   └──────────────────┘       └──────────────────┘
```

### Password Grant (Usuario)

```
┌─────────┐                  ┌──────────┐                  ┌─────────┐
│ Browser │                  │ Frontend │                  │ Backend │
└────┬────┘                  └────┬─────┘                  └────┬────┘
     │                            │                             │
     │ 1. Ingresa email/password  │                             │
     ├───────────────────────────>│                             │
     │                            │                             │
     │                            │ 2. POST /spree_oauth/token  │
     │                            │    {grant_type: "password", │
     │                            │     username, password}     │
     │                            ├────────────────────────────>│
     │                            │                             │
     │                            │ 3. Valida usuario en DB     │
     │                            │    Verifica password        │
     │                            │<────────────────────────────┤
     │                            │    {access_token, ...}      │
     │                            │                             │
     │ 4. Guarda token            │                             │
     │    Redirige a /admin.html  │                             │
     │<───────────────────────────┤                             │
     │                            │                             │
```

### Client Credentials (Aplicación)

```
┌─────────────┐               ┌─────────┐
│ Application │               │ Backend │
└──────┬──────┘               └────┬────┘
       │                           │
       │ 1. POST /spree_oauth/token│
       │    {grant_type:            │
       │     "client_credentials",  │
       │     client_id, secret}     │
       ├──────────────────────────>│
       │                           │
       │ 2. Valida credenciales    │
       │    de la aplicación       │
       │<──────────────────────────┤
       │    {access_token, ...}    │
       │                           │
       │ 3. Usa token en API calls │
       ├──────────────────────────>│
       │                           │
```

---

## 🔧 Configuración del Backend

### Nginx Frontend Load Balancer

Para que el login funcione correctamente, el nginx del frontend debe hacer proxy de las rutas OAuth al backend:

```nginx
# load-balancers/frontend-nginx.conf

# Proxy a OAuth endpoint (backend)
location /spree_oauth/ {
  proxy_pass http://backend-lb/spree_oauth/;
  
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
  proxy_set_header Content-Type application/json;
  
  proxy_connect_timeout 60s;
  proxy_send_timeout 60s;
  proxy_read_timeout 60s;
}

# Proxy al backend API
location /api/ {
  proxy_pass http://backend-lb/api/;
  
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
}
```

**Importante**: Sin esta configuración, las peticiones a `/spree_oauth/token` desde el frontend irían al puerto 3000 (frontends estáticos) en lugar del puerto 4000 (backend API).

### Usuario Admin

```ruby
# backend/db/seeds/setup_admin_api.rb
admin = Spree::User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.password = 'spree123'
  user.password_confirmation = 'spree123'
end

# Agregar rol de admin
admin_role = Spree::Role.find_or_create_by!(name: 'admin')
admin.spree_roles << admin_role unless admin.spree_roles.include?(admin_role)
```

### OAuth Application

```ruby
# backend/db/seeds/setup_oauth_app.rb
app = Spree::OauthApplication.find_or_create_by!(name: 'Admin Panel') do |application|
  application.scopes = 'admin'
  application.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
end

puts "Client ID: #{app.uid}"
puts "Client Secret: #{app.secret}"
```

**Credenciales OAuth generadas**:
- Client ID: `sDdImYdx_kqvffaOTNxYsOtX_5w1XQGkxrr9RaTLIpg`
- Client Secret: `$2a$12$u7yy7JgbJuyKp25BGkskHOz7Ei1Yv3pH3KzOq72RnzhMVWaijAswy`

---

## 🛡️ Seguridad

### ✅ Implementado (Desarrollo)

- ✅ Tokens OAuth2 estándar
- ✅ Password hashing (bcrypt)
- ✅ Token expiration (30 días)
- ✅ HTTPS en Spree por defecto
- ✅ CORS configurado

### ⚠️ Recomendaciones para Producción

1. **No exponer client_secret en frontend**
   ```javascript
   // ❌ MAL: Client secret visible en el navegador
   const response = await fetch('/spree_oauth/token', {
     body: JSON.stringify({ client_secret: 'xxx' })
   });
   
   // ✅ BIEN: Backend proxy que oculta el secret
   const response = await fetch('/api/auth/login', {
     body: JSON.stringify({ username, password })
   });
   ```

2. **Usar HTTPS obligatorio**
   ```nginx
   # Redirigir HTTP a HTTPS
   server {
     listen 80;
     return 301 https://$host$request_uri;
   }
   ```

3. **Implementar rate limiting**
   ```ruby
   # Gemfile
   gem 'rack-attack'
   
   # config/initializers/rack_attack.rb
   Rack::Attack.throttle('auth/ip', limit: 5, period: 60) do |req|
     req.ip if req.path == '/spree_oauth/token'
   end
   ```

---

## � Troubleshooting

### Error: 404 en /spree_oauth/token

**Síntoma**: El login falla con error 404 Not Found

**Causa**: El nginx del frontend no tiene configurado el proxy para `/spree_oauth/`

**Solución**:
```bash
# 1. Verificar configuración de nginx
docker exec frontend-lb cat /etc/nginx/nginx.conf | grep -A 10 "spree_oauth"

# 2. Si no existe, agregar en frontend-nginx.conf:
location /spree_oauth/ {
  proxy_pass http://backend-lb/spree_oauth/;
  # ... headers
}

# 3. Reiniciar nginx
docker restart frontend-lb
```

### Error: CORS al hacer login

**Síntoma**: Error `Access-Control-Allow-Origin` en la consola del navegador

**Causa**: Backend no permite peticiones cross-origin

**Solución**:
```ruby
# backend/config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '/api/*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :options]
    resource '/spree_oauth/*', headers: :any, methods: [:post, :options]
  end
end
```

### Error: "Invalid credentials"

**Síntoma**: Login rechazado con credenciales correctas

**Causa**: Usuario no tiene rol de admin

**Solución**:
```bash
docker exec spree-backend-1 bundle exec rails runner "
  admin = Spree::User.find_by(email: 'admin@example.com')
  role = Spree::Role.find_or_create_by!(name: 'admin')
  admin.spree_roles << role unless admin.spree_roles.include?(role)
  puts '✓ Admin role added'
"
```

### Error: Token expirado

**Síntoma**: Panel redirige a login después de haber iniciado sesión

**Causa**: Token almacenado en localStorage expiró

**Solución**:
```javascript
// En la consola del navegador (F12):
localStorage.clear();
// Luego hacer login nuevamente
```

### Verificar que todo funciona

```bash
# 1. Test OAuth a través del frontend LB (puerto 3000)
curl -X POST http://localhost:3000/spree_oauth/token \
  -H "Content-Type: application/json" \
  -d '{
    "grant_type": "password",
    "username": "admin@example.com",
    "password": "spree123",
    "client_id": "sDdImYdx_kqvffaOTNxYsOtX_5w1XQGkxrr9RaTLIpg",
    "client_secret": "$2a$12$u7yy7JgbJuyKp25BGkskHOz7Ei1Yv3pH3KzOq72RnzhMVWaijAswy"
  }'

# 2. Verificar logs del frontend LB
docker logs frontend-lb --tail 20

# 3. Verificar que backend responde
docker logs backend-lb --tail 20

# 4. Estado de los contenedores
docker ps --filter "name=frontend" --filter "name=backend"
```

---

## �📝 Comandos Útiles

### Ver usuarios admin

```bash
docker exec spree-backend-1 bundle exec rails runner "
  Spree::User.joins(:spree_roles).where(spree_roles: { name: 'admin' }).each do |u|
    puts \"#{u.email} (ID: #{u.id})\"
  end
"
```

### Crear nuevo usuario admin

```bash
docker exec spree-backend-1 bundle exec rails runner "
  user = Spree::User.create!(
    email: 'nuevo@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )
  admin_role = Spree::Role.find_or_create_by!(name: 'admin')
  user.spree_roles << admin_role
  puts \"✓ Usuario creado: #{user.email}\"
"
```

---

## ✅ Resumen

### Password Grant (Usuario) ✅ **Implementado**

```
Login Form → Email/Password → OAuth Token → Admin Panel
```

- ✅ Formulario de login en `/login.html`
- ✅ Usuario admin: `admin@example.com` / `spree123`
- ✅ Token almacenado en localStorage
- ✅ Verificación de expiración
- ✅ Logout funcional

### Client Credentials (Aplicación) ✅ **Disponible**

```
App Config → Client ID/Secret → OAuth Token → API Calls
```

- ✅ Útil para scripts y automatizaciones
- ✅ No requiere usuario específico
- ✅ Mismo endpoint `/spree_oauth/token`

---

**Fecha**: Diciembre 1, 2025  
**Versión**: 2.0.0  
**Sistema**: Arquitectura Distribuida con Spree Commerce
