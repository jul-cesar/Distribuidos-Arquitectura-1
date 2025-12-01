# 🚀 Guía de Despliegue - Arquitectura Distribuida Spree Commerce

## 📋 Requisitos Previos

- Docker Desktop instalado y corriendo
- Git
- Al menos 8GB de RAM disponible
- Puertos libres: 3000, 3001, 3002, 3003, 4000, 5432

## 🔧 Pasos para Desplegar

### 1. Clonar el Repositorio

```powershell
git clone https://github.com/jul-cesar/Distribuidos-Arquitectura-1.git
cd Distribuidos-Arquitectura-1
```

### 2. Crear las Redes de Docker

```powershell
docker network create internal_net
docker network create dmz_net
```

### 3. Construir las Imágenes de los Backends

```powershell
# Esto tomará varios minutos (aproximadamente 5-10 minutos)
docker-compose build spree-backend-1
```

### 4. Levantar Todo el Sistema

```powershell
# Levantar en orden: Base de datos → Backends → Load Balancers → Frontends
docker-compose up -d
```

### 5. Verificar que Todo Esté Funcionando

```powershell
# Ver todos los contenedores
docker ps

# Verificar la replicación de la base de datos
docker exec db-master psql -U spree -d spree_db -c "SELECT * FROM pg_stat_replication;"

# Verificar los health checks
curl http://localhost:3000/health
curl http://localhost:4000/health
```

### 6. Acceder a la Aplicación

- **🛍️ Tienda**: http://localhost:3000
- **🛠️ Panel de Administración**: http://localhost:3000/admin.html
- **📡 API Backend**: http://localhost:4000/api/v2/storefront/products

**Credenciales Admin**:
- Email: `admin@example.com`
- Password: `spree123`

## 🌐 URLs de Acceso

| Servicio | URL |
|----------|-----|
| Frontend Principal | http://localhost:3000 |
| Backend API | http://localhost:4000 |
| Spree Admin | http://localhost:4000/admin |
| Backend 1 (directo) | http://localhost:3001 |
| Backend 2 (directo) | http://localhost:3002 |
| Backend 3 (directo) | http://localhost:3003 |

## 📊 Arquitectura del Sistema

- **Frontend**: 3 instancias + Load Balancer Nginx (puerto 3000)
- **Backend**: 3 instancias Spree Commerce + Load Balancer Nginx (puerto 4000)
- **Base de Datos**: PostgreSQL Master + 2 Réplicas (puerto 5432)

## 🛑 Comandos Útiles

### Detener Todo
```powershell
docker-compose down
```

### Detener y Eliminar Volúmenes (CUIDADO: Borra la BD)
```powershell
docker-compose down -v
```

### Ver Logs
```powershell
# Logs de todos los servicios
docker-compose logs -f

# Logs de un servicio específico
docker-compose logs -f spree-backend-1
docker-compose logs -f db-master
docker-compose logs -f frontend-lb
```

### Reiniciar un Servicio
```powershell
docker-compose restart spree-backend-1
```

### Reconstruir una Imagen
```powershell
docker-compose build --no-cache spree-backend-1
```

## 🔍 Verificación del Sistema

### Verificar Replicación de Base de Datos
```powershell
# En el master - Ver réplicas conectadas
docker exec db-master psql -U spree -d spree_db -c "SELECT application_name, state, sync_state FROM pg_stat_replication;"

# En una réplica - Verificar modo de recuperación
docker exec db-replica1 psql -U spree -d spree_db -c "SELECT pg_is_in_recovery();"
```

### Verificar Balanceo de Carga
```powershell
# Hacer varias peticiones y ver los logs
for ($i=1; $i -le 10; $i++) { 
    curl http://localhost:3000 -UseBasicParsing | Out-Null
}
docker logs frontend-lb --tail 10
```

## ⚠️ Solución de Problemas

### Si un contenedor no inicia:
```powershell
# Ver los logs del contenedor
docker logs nombre-del-contenedor

# Reiniciar el contenedor
docker-compose restart nombre-del-contenedor
```

### Si hay problemas con los puertos:
```powershell
# Verificar qué está usando un puerto
netstat -ano | findstr :3000
```

### Si necesitas limpiar todo y empezar de nuevo:
```powershell
docker-compose down -v
docker system prune -a --volumes
docker network create internal_net
docker network create dmz_net
docker-compose build spree-backend-1
docker-compose up -d
```

## 📝 Notas Importantes

1. **Primera vez**: La construcción de las imágenes de backend tomará 5-10 minutos
2. **Inicialización**: La primera vez que se levantan los backends, ejecutan migraciones de BD (1-2 minutos)
3. **Recursos**: El sistema completo usa aproximadamente 4-6 GB de RAM
4. **Puertos**: Asegúrate de que los puertos 3000, 3001, 3002, 3003, 4000 y 5432 estén libres

## 🎯 Credenciales por Defecto

**Base de Datos:**
- Usuario: `spree`
- Password: `spreepass`
- Base de datos: `spree_db`

**Usuario de Replicación:**
- Usuario: `repluser`
- Password: `replpass`

## 📚 Más Información

Para más detalles sobre la arquitectura y configuración, consulta los archivos:
- `docker-compose.yml` - Configuración de todos los servicios
- `backend/Dockerfile` - Imagen de Spree Commerce
- `load-balancers/backend-nginx.conf` - Configuración del LB backend
- `load-balancers/frontend-nginx.conf` - Configuración del LB frontend
- `database/init/01-configure-master.sh` - Configuración de replicación
