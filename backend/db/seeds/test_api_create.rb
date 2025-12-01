# Test: Crear producto via Platform API

require 'net/http'
require 'json'
require 'uri'

puts "🧪 Probando creación de producto via Platform API...\n"

# Token
token = '78450cf49d7be06afa83acee542e8b6ce1481634faecfbb136e89c409b3c593b'

# Datos del producto
product_data = {
  product: {
    name: 'Producto de Prueba API',
    description: 'Este producto fue creado via Platform API para testing',
    price: 49.99,
    status: 'active',
    available_on: Time.now.iso8601
  }
}

# Endpoint
uri = URI('http://localhost:4000/api/v2/platform/products')

# Request
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Post.new(uri.path)
request['Content-Type'] = 'application/json'
request['Authorization'] = "Bearer #{token}"
request.body = product_data.to_json

puts "📡 Enviando request a #{uri}..."
puts "📦 Datos: #{product_data.to_json}\n"

# Enviar
begin
  response = http.request(request)
  
  puts "📊 Respuesta:"
  puts "  Status: #{response.code} #{response.message}"
  
  if response.code.to_i >= 200 && response.code.to_i < 300
    result = JSON.parse(response.body)
    puts "  ✅ Producto creado exitosamente!"
    puts "  ID: #{result.dig('data', 'id')}"
    puts "  Nombre: #{result.dig('data', 'attributes', 'name')}"
    puts "  Precio: #{result.dig('data', 'attributes', 'display_price')}"
  else
    puts "  ❌ Error: #{response.body}"
  end
rescue => e
  puts "  ❌ Exception: #{e.message}"
end

puts "\n✅ Test completado!"
