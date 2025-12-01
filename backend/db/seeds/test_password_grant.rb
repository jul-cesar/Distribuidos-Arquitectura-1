# Enable password grant type for OAuth application
app = Spree::OauthApplication.find_or_create_by!(name: 'Admin Panel') do |application|
  application.scopes = 'admin'
  application.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
end

puts "OAuth Application: #{app.name}"
puts "Client ID: #{app.uid}"
puts "Secret: #{app.secret}"
puts "Scopes: #{app.scopes}"

# Test if password grant works
admin = Spree::User.find_by(email: 'admin@example.com')
if admin
  puts "\n✓ Admin user found: #{admin.email}"
  puts "  User ID: #{admin.id}"
  puts "  Admin role: #{admin.has_spree_role?(:admin)}"
else
  puts "\n✗ Admin user not found"
end

puts "\n=== Test Password Grant ==="
puts "To test, use:"
puts "POST http://localhost:4000/spree_oauth/token"
puts "Body:"
puts <<-JSON
{
  "grant_type": "password",
  "username": "admin@example.com",
  "password": "spree123",
  "client_id": "#{app.uid}",
  "client_secret": "#{app.secret}"
}
JSON
