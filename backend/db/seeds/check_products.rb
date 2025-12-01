Spree::Product.all.limit(3).each do |p|
  puts [p.id, p.name, p.available_on, p.status].join(' | ')
end
