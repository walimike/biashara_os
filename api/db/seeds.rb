org = Organization.find_or_create_by!(slug: "demo-shop") do |o|
  o.name = "Demo Biashara Shop"
  o.currency = "KES"
  o.enabled_modules = %w[order_pad pos]
  o.plan = "starter"
end

user = org.users.find_or_initialize_by(email: "demo@biashara.test")
if user.new_record?
  user.assign_attributes(
    name: "Demo Owner",
    password: "password123",
    password_confirmation: "password123",
    role: "owner"
  )
  user.save!
end

products = [
  { name: "T-Shirt", sku: "TSH-001", price_cents: 150_000, stock_quantity: 20 },
  { name: "Sneakers", sku: "SNK-001", price_cents: 450_000, stock_quantity: 8 },
  { name: "Phone Case", sku: "PHC-001", price_cents: 25_000, stock_quantity: 50 }
]

products.each do |attrs|
  org.products.find_or_create_by!(sku: attrs[:sku]) do |p|
    p.assign_attributes(attrs)
  end
end

customer = org.customers.find_or_create_by!(phone: "254712345678") do |c|
  c.name = "Jane Customer"
  c.email = "jane@example.com"
end

if org.orders.none?
  order = org.orders.create!(
    user: user,
    customer: customer,
    source: "order_pad",
    status: "pending",
    payment_method: "mpesa",
    payment_status: "unpaid",
    notes: "IG order - size M, blue",
    order_items_attributes: [
      { product: org.products.find_by!(sku: "TSH-001"), name: "T-Shirt", quantity: 1, unit_price_cents: 150_000 }
    ]
  )
  order.recalculate_totals!
end

puts "Seeded demo org: #{org.name} (#{org.slug})"
puts "Login: demo@biashara.test / password123"
