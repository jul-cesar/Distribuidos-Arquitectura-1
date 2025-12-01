# Setup admin user and API token for Platform API access

puts "🔧 Configurando acceso a Platform API..."

# Create or find admin user
admin_email = ENV.fetch('SPREE_ADMIN_EMAIL', 'admin@example.com')
admin_password = ENV.fetch('SPREE_ADMIN_PASSWORD', 'spree123')

admin_user = Spree::User.find_by(email: admin_email)

if admin_user
  puts "✓ Usuario admin encontrado: #{admin_email}"
else
  puts "📝 Creando usuario admin..."
  admin_user = Spree::User.create!(
    email: admin_email,
    password: admin_password,
    password_confirmation: admin_password
  )
  puts "✓ Usuario admin creado: #{admin_email}"
end

# Create API key for Platform API
puts "\n🔑 Generando API token..."

# Check if Spree::OauthAccessToken exists (Spree 4.3+)
if defined?(Spree::OauthAccessToken)
  # Find or create application
  app = Spree::OauthApplication.find_or_create_by!(name: 'Admin Panel') do |application|
    application.scopes = 'admin'
    application.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
  end

  # Create access token
  token = Spree::OauthAccessToken.create!(
    resource_owner_id: admin_user.id,
    application_id: app.id,
    scopes: 'admin',
    expires_in: 7200,
    use_refresh_token: true
  )

  puts "\n" + "="*70
  puts "✅ CONFIGURACIÓN COMPLETADA"
  puts "="*70
  puts "\nCredenciales de Admin:"
  puts "  Email:    #{admin_email}"
  puts "  Password: #{admin_password}"
  puts "\nAPI Token (válido por 2 horas):"
  puts "  #{token.token}"
  puts "\nUso en requests:"
  puts "  Authorization: Bearer #{token.token}"
  puts "="*70
else
  puts "\n⚠️  OauthAccessToken no disponible en esta versión de Spree"
  puts "Usando autenticación básica con usuario admin"
  puts "\nCredenciales:"
  puts "  Email:    #{admin_email}"
  puts "  Password: #{admin_password}"
end
