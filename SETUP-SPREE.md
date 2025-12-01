# 🛍️ Configuración de Spree Commerce

Este documento detalla cómo configurar Spree para que funcione con el frontend.

## 📦 Configuración Implementada

### 1. CORS (Cross-Origin Resource Sharing)

Se ha configurado CORS para permitir que el frontend se comunique con la API:

**Archivo**: `backend/config/initializers/cors.rb`

```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'  # En producción, cambiar a dominios específicos
    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

**Gema agregada**: `rack-cors` en `Gemfile`

### 2. Productos de Prueba

Se creó un script para poblar la base de datos con productos de demostración:

**Archivo**: `backend/db/seeds/sample_products.rb`

- **Electrónica**: Laptops, smartphones, auriculares, tablets, smartwatches
- **Ropa**: Camisetas, jeans, zapatillas, chaquetas, sudaderas
- **Libros**: Programación, sistemas distribuidos, clean code, Docker
- **Hogar**: Lámparas, cafeteras, aspiradoras, toallas

## 🚀 Comandos para Configurar

### 1. Reconstruir la Imagen del Backend

```powershell
docker-compose build spree-backend-1
```

### 2. Reiniciar los Backends

```powershell
docker-compose restart spree-backend-1 spree-backend-2 spree-backend-3
```

### 3. Crear Productos de Prueba

```powershell
# Ejecutar seeds en el contenedor
docker exec spree-backend-1 bundle exec rails db:seed
```

### 4. Verificar que la API Funciona

```powershell
# Probar el endpoint de productos
curl http://localhost:4000/api/v2/storefront/products -UseBasicParsing
```

## 📡 Endpoints de la API Spree

### Storefront API v2

- **Productos**: `/api/v2/storefront/products`
- **Producto específico**: `/api/v2/storefront/products/:id`
- **Categorías (Taxons)**: `/api/v2/storefront/taxons`
- **Carrito**: `/api/v2/storefront/cart`
- **Checkout**: `/api/v2/storefront/checkout`

### Ejemplos de Peticiones

#### Listar Productos
```powershell
curl http://localhost:4000/api/v2/storefront/products -UseBasicParsing
```

#### Buscar Productos
```powershell
curl "http://localhost:4000/api/v2/storefront/products?filter[name]=laptop" -UseBasicParsing
```

#### Obtener Producto Específico
```powershell
curl http://localhost:4000/api/v2/storefront/products/1 -UseBasicParsing
```

## 🔧 Troubleshooting

### Error: CORS no funciona

**Solución**: Verificar que rack-cors esté instalado:
```powershell
docker exec spree-backend-1 bundle list | Select-String "rack-cors"
```

### Error: No hay productos

**Solución**: Ejecutar seeds:
```powershell
docker exec spree-backend-1 bundle exec rails db:seed
```

### Error: API no responde

**Solución**: Verificar que los backends estén corriendo:
```powershell
docker ps | Select-String "spree-backend"
```

Ver logs:
```powershell
docker logs spree-backend-1 --tail 50
```

## 🎯 Próximos Pasos

1. **Autenticación**: Configurar OAuth tokens para API
2. **Imágenes de Productos**: Agregar imágenes reales a los productos
3. **Carrito Persistente**: Implementar carrito con API de Spree
4. **Checkout Real**: Integrar proceso de pago completo
5. **Admin Panel**: Configurar usuario admin para gestión

## 📚 Documentación Oficial

- [Spree API v2 Docs](https://dev-docs.spreecommerce.org/api/v2)
- [Spree Storefront API](https://dev-docs.spreecommerce.org/api/v2/storefront)
- [Spree Platform API](https://dev-docs.spreecommerce.org/api/v2/platform)
