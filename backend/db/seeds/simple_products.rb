# Script simple para crear productos
puts "Eliminando productos existentes..."
Spree::Product.delete_all
FriendlyId::Slug.where(sluggable_type: 'Spree::Product').delete_all

puts "Creando 18 productos..."
shipping_category = Spree::ShippingCategory.first_or_create!(name: 'Default')

products = [
  {name: "Laptop Pro 2024", price: 1299.99},
  {name: "Smartphone X", price: 899.99},
  {name: "Auriculares Bluetooth Premium", price: 199.99},
  {name: "Tablet Pro 12", price: 699.99},
  {name: "Smart Watch Series 6", price: 399.99},
  {name: "Camiseta Premium Algodón", price: 29.99},
  {name: "Jeans Clásicos", price: 59.99},
  {name: "Zapatillas Deportivas", price: 89.99},
  {name: "Chaqueta de Cuero", price: 199.99},
  {name: "Sudadera con Capucha", price: 49.99},
  {name: "El Arte de Programar", price: 49.99},
  {name: "Sistemas Distribuidos Modernos", price: 59.99},
  {name: "Clean Code", price: 44.99},
  {name: "Docker y Kubernetes", price: 54.99},
  {name: "Lámpara LED Moderna", price: 79.99},
  {name: "Cafetera Automática", price: 149.99},
  {name: "Aspiradora Robot", price: 299.99},
  {name: "Set de Toallas Premium", price: 69.99}
]

products.each do |data|
  product = Spree::Product.new(
    name: data[:name],
    price: data[:price],
    available_on: Time.current,
    shipping_category: shipping_category
  )
  
  begin
    product.save(validate: false)
    product.master.stock_items.first.set_count_on_hand(100)
    puts "✓ Creado: #{product.name}"
  rescue => e
    puts "✗ Error creando #{data[:name]}: #{e.message}"
  end
end

puts "\n✅ Proceso completo. Total de productos: #{Spree::Product.count}"
