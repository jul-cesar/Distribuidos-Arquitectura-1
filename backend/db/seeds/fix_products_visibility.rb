# Fix product visibility for storefront API
puts "🔧 Actualizando visibilidad de productos..."

store = Spree::Store.first
puts "Store: #{store&.name}"

Spree::Product.find_each do |product|
  product.update_columns(
    available_on: 1.day.ago,
    status: 'active'
  )
  
  # Asegurar que cada producto tenga store associations
  unless product.stores.include?(store)
    product.stores << store if store
  end
  
  puts "✓ #{product.name} - available_on: #{product.available_on}"
end

puts "\n📊 Total productos: #{Spree::Product.count}"
puts "📊 Productos disponibles: #{Spree::Product.available.count}"
