# Script para verificar y configurar permisos de administrador

puts "=== Verificando usuario administrador ==="
puts ""

# Buscar el primer usuario (generalmente el admin)
user = Spree::User.first

if user.nil?
  puts "❌ No hay usuarios en el sistema"
  puts "Ejecuta: docker exec -it backend-1 rake spree_sample:load"
  exit
end

puts "Usuario encontrado:"
puts "  ID: #{user.id}"
puts "  Email: #{user.email}"
puts ""

# Verificar si tiene rol de admin
has_admin_role = user.has_spree_role?(:admin)
puts "¿Tiene rol de admin?: #{has_admin_role ? '✅ SÍ' : '❌ NO'}"
puts ""

# Si no tiene rol de admin, agregarlo
unless has_admin_role
  puts "Agregando rol de administrador..."
  admin_role = Spree::Role.find_or_create_by!(name: 'admin')
  user.spree_roles << admin_role unless user.spree_roles.include?(admin_role)
  user.save!
  puts "✅ Rol de administrador agregado"
  puts ""
end

# Verificar tokens activos
puts "=== Tokens de acceso ==="
tokens = Spree::OauthAccessToken.where(resource_owner_id: user.id, revoked_at: nil)
puts "Tokens activos: #{tokens.count}"

if tokens.any?
  tokens.each_with_index do |token, index|
    puts ""
    puts "Token #{index + 1}:"
    puts "  ID: #{token.id}"
    puts "  Creado: #{token.created_at}"
    puts "  Expira en: #{token.expires_in} segundos"
    puts "  Revocado: #{token.revoked? ? 'Sí' : 'No'}"
  end
else
  puts "No hay tokens activos. Crear uno desde /login.html"
end

puts ""
puts "=== Resumen ==="
puts "✅ Usuario: #{user.email}"
puts "✅ Es admin: #{user.has_spree_role?(:admin)}"
puts "✅ Listo para usar el panel de administración"
puts ""
