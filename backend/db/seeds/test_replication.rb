# Test replication by creating a product
puts "🔄 Creando producto de prueba para verificar replicación..."

p = Spree::Product.create!(
  name: 'PRODUCTO PRUEBA REPLICACIÓN',
  price: 99.99,
  available_on: 1.day.ago,
  status: 'active'
)

puts "✓ Producto creado con ID: #{p.id}"
puts "✓ Nombre: #{p.name}"
puts "✓ Precio: $#{p.price}"
