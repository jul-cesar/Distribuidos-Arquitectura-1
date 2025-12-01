# Give admin role to user
admin = Spree::User.find_by(email: 'admin@example.com')

if admin
  # Add admin role
  admin_role = Spree::Role.find_or_create_by!(name: 'admin')
  
  unless admin.spree_roles.include?(admin_role)
    admin.spree_roles << admin_role
    puts "✓ Admin role added to #{admin.email}"
  else
    puts "✓ User #{admin.email} already has admin role"
  end
  
  puts "Roles: #{admin.spree_roles.pluck(:name).join(', ')}"
else
  puts "✗ Admin user not found"
end
