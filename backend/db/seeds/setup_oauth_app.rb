# Check and create OAuth application

puts "🔍 Verificando aplicación OAuth..."

# Find or create OAuth application
app = Spree::OauthApplication.find_or_create_by!(name: 'Admin Panel') do |application|
  application.scopes = 'admin'
  application.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
end

puts "\n✅ Aplicación OAuth configurada:"
puts "="*70
puts "Name:          #{app.name}"
puts "UID (client_id): #{app.uid}"
puts "Secret:        #{app.secret}"
puts "Scopes:        #{app.scopes}"
puts "="*70

puts "\n📝 Para obtener un token, hacer POST a:"
puts "http://localhost:4000/spree_oauth/token"
puts "\nCon el body:"
puts <<~JSON
{
  "grant_type": "client_credentials",
  "client_id": "#{app.uid}",
  "client_secret": "#{app.secret}",
  "scope": "admin"
}
JSON

puts "\n💡 Ejemplo con curl:"
puts <<~CURL
curl -X POST http://localhost:4000/spree_oauth/token \\
  -H "Content-Type: application/json" \\
  -d '{
    "grant_type": "client_credentials",
    "client_id": "#{app.uid}",
    "client_secret": "#{app.secret}",
    "scope": "admin"
  }'
CURL
