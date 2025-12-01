# db/seeds/sample_products.rb
# Script para crear productos de prueba en Spree

puts "🌱 Creando productos de prueba..."

# Verificar si ya existen productos
if Spree::Product.count > 0
  puts "✅ Ya existen productos en la base de datos (#{Spree::Product.count} productos)"
  puts "💡 Para recrear los productos, ejecuta: rails db:seed:replant"
  exit
end

# Crear taxonomías (categorías)
electronics = Spree::Taxon.find_or_create_by!(
  name: "Electrónica",
  parent: Spree::Taxon.find_by(name: "Categories"),
  taxonomy: Spree::Taxonomy.first
)

clothing = Spree::Taxon.find_or_create_by!(
  name: "Ropa",
  parent: Spree::Taxon.find_by(name: "Categories"),
  taxonomy: Spree::Taxonomy.first
)

books = Spree::Taxon.find_or_create_by!(
  name: "Libros",
  parent: Spree::Taxon.find_by(name: "Categories"),
  taxonomy: Spree::Taxonomy.first
)

home = Spree::Taxon.find_or_create_by!(
  name: "Hogar",
  parent: Spree::Taxon.find_by(name: "Categories"),
  taxonomy: Spree::Taxonomy.first
)

# Productos de Electrónica
[
  {
    name: "Laptop Pro 2024",
    description: "Potente laptop para profesionales con última generación de procesador, 16GB RAM y 512GB SSD",
    price: 1299.99,
    taxon: electronics
  },
  {
    name: "Smartphone X",
    description: "El smartphone más avanzado del mercado con cámara de 108MP y 5G",
    price: 899.99,
    taxon: electronics
  },
  {
    name: "Auriculares Bluetooth Premium",
    description: "Sonido premium con cancelación activa de ruido y 30 horas de batería",
    price: 199.99,
    taxon: electronics
  },
  {
    name: "Tablet Pro 12",
    description: "Tablet profesional de 12 pulgadas con stylus incluido",
    price: 699.99,
    taxon: electronics
  },
  {
    name: "Smart Watch Series 6",
    description: "Reloj inteligente con monitoreo de salud y GPS integrado",
    price: 399.99,
    taxon: electronics
  }
].each do |product_data|
  product = Spree::Product.create!(
    name: product_data[:name],
    description: product_data[:description],
    price: product_data[:price],
    available_on: Time.current,
    shipping_category: Spree::ShippingCategory.first
  )
  
  product.taxons << product_data[:taxon]
  
  # Crear variante por defecto con stock
  variant = product.master
  variant.stock_items.first.update(count_on_hand: 100)
  
  puts "✓ Creado: #{product.name}"
end

# Productos de Ropa
[
  {
    name: "Camiseta Premium Algodón",
    description: "Camiseta de algodón 100% premium, suave y duradera",
    price: 29.99,
    taxon: clothing
  },
  {
    name: "Jeans Clásicos",
    description: "Jeans de mezclilla de alta calidad, corte clásico",
    price: 59.99,
    taxon: clothing
  },
  {
    name: "Zapatillas Deportivas",
    description: "Comodidad y estilo para tus entrenamientos y día a día",
    price: 89.99,
    taxon: clothing
  },
  {
    name: "Chaqueta de Cuero",
    description: "Chaqueta de cuero genuino, elegante y resistente",
    price: 199.99,
    taxon: clothing
  },
  {
    name: "Sudadera con Capucha",
    description: "Sudadera cómoda perfecta para cualquier ocasión",
    price: 49.99,
    taxon: clothing
  }
].each do |product_data|
  product = Spree::Product.create!(
    name: product_data[:name],
    description: product_data[:description],
    price: product_data[:price],
    available_on: Time.current,
    shipping_category: Spree::ShippingCategory.first
  )
  
  product.taxons << product_data[:taxon]
  variant = product.master
  variant.stock_items.first.update(count_on_hand: 50)
  
  puts "✓ Creado: #{product.name}"
end

# Productos de Libros
[
  {
    name: "El Arte de Programar",
    description: "Libro esencial para desarrolladores, desde principiantes hasta expertos",
    price: 49.99,
    taxon: books
  },
  {
    name: "Sistemas Distribuidos Modernos",
    description: "Guía completa sobre arquitecturas distribuidas y microservicios",
    price: 59.99,
    taxon: books
  },
  {
    name: "Clean Code",
    description: "Manual de estilo para el desarrollo ágil de software",
    price: 44.99,
    taxon: books
  },
  {
    name: "Docker y Kubernetes",
    description: "Aprende containerización y orquestación de aplicaciones",
    price: 54.99,
    taxon: books
  }
].each do |product_data|
  product = Spree::Product.create!(
    name: product_data[:name],
    description: product_data[:description],
    price: product_data[:price],
    available_on: Time.current,
    shipping_category: Spree::ShippingCategory.first
  )
  
  product.taxons << product_data[:taxon]
  variant = product.master
  variant.stock_items.first.update(count_on_hand: 75)
  
  puts "✓ Creado: #{product.name}"
end

# Productos de Hogar
[
  {
    name: "Lámpara LED Moderna",
    description: "Iluminación inteligente con control por app y cambio de color",
    price: 79.99,
    taxon: home
  },
  {
    name: "Cafetera Automática",
    description: "Cafetera programable con molinillo integrado",
    price: 149.99,
    taxon: home
  },
  {
    name: "Aspiradora Robot",
    description: "Limpieza automática con mapeo inteligente del hogar",
    price: 299.99,
    taxon: home
  },
  {
    name: "Set de Toallas Premium",
    description: "Set de 6 toallas de algodón egipcio ultra suaves",
    price: 69.99,
    taxon: home
  }
].each do |product_data|
  product = Spree::Product.create!(
    name: product_data[:name],
    description: product_data[:description],
    price: product_data[:price],
    available_on: Time.current,
    shipping_category: Spree::ShippingCategory.first
  )
  
  product.taxons << product_data[:taxon]
  variant = product.master
  variant.stock_items.first.update(count_on_hand: 30)
  
  puts "✓ Creado: #{product.name}"
end

puts "\n✅ ¡Productos creados exitosamente!"
puts "📊 Total de productos: #{Spree::Product.count}"
puts "🏷️  Categorías: #{Spree::Taxon.where.not(parent_id: nil).count}"
