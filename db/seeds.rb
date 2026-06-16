# Categories
skincare  = Category.find_or_create_by!(slug: "skincare")  { |c| c.name = "Skincare" }
makeup    = Category.find_or_create_by!(slug: "makeup")    { |c| c.name = "Makeup" }
haircare  = Category.find_or_create_by!(slug: "haircare")  { |c| c.name = "Haircare" }

puts "Categories: #{Category.count}"

# Sample products — replace with real inventory before launch
skincare_products = [
  { name: "L'Oréal Revitalift Serum", description: "Anti-ageing serum with hyaluronic acid. Reduces fine lines in 4 weeks.", price: 799, stock_count: 50 },
  { name: "Neutrogena Hydro Boost Gel", description: "Oil-free water gel moisturiser with hyaluronic acid for 48hr hydration.", price: 599, stock_count: 40 },
  { name: "Lakme Absolute SPF 45 Sunscreen", description: "Lightweight daily sunscreen with SPF 45 and PA+++ protection.", price: 349, stock_count: 60 },
  { name: "Himalaya Purifying Neem Face Wash", description: "Neem and turmeric face wash for oily and acne-prone skin.", price: 149, stock_count: 100 },
  { name: "Biotique Bio Honey Gel Moisturiser", description: "Soothing honey-based moisturiser for normal to dry skin.", price: 199, stock_count: 75 },
]

makeup_products = [
  { name: "Maybelline Fit Me Foundation", description: "Natural-finish liquid foundation. Matches all Indian skin tones. 30ml.", price: 449, stock_count: 45 },
  { name: "Lakme Eyeconic Kajal", description: "Smudge-proof, water-resistant kajal pencil. Lasts 16 hours.", price: 199, stock_count: 80 },
  { name: "Swiss Beauty Ultra Smooth Matte Lipstick", description: "Highly pigmented matte lipstick with vitamin E. 24 shades.", price: 249, stock_count: 60 },
  { name: "NYX Micro Brow Pencil", description: "Ultra-fine brow pencil for precise, hair-like strokes.", price: 699, stock_count: 30 },
  { name: "Colorbar Nail Lacquer", description: "Long-lasting nail polish, 8ml. Available in 150+ shades.", price: 175, stock_count: 90 },
]

haircare_products = [
  { name: "Indulekha Bringha Hair Oil", description: "Ayurvedic oil for hair fall control. Self-comb applicator.", price: 449, stock_count: 50 },
  { name: "Dove Intense Repair Shampoo", description: "Keratin repair shampoo for damaged and frizzy hair. 340ml.", price: 299, stock_count: 70 },
  { name: "Tresemmé Keratin Smooth Conditioner", description: "Frizz-control conditioner with marula oil and keratin. 190ml.", price: 249, stock_count: 55 },
  { name: "Streax Pro Serum", description: "Argan micro conditioning serum for smooth, shiny hair. 100ml.", price: 349, stock_count: 40 },
  { name: "Biotique Bio Kelp Protein Shampoo", description: "Protein-enriched shampoo for hair thickening and volume. 340ml.", price: 179, stock_count: 65 },
]

[[skincare, skincare_products], [makeup, makeup_products], [haircare, haircare_products]].each do |category, items|
  items.each do |attrs|
    Product.find_or_create_by!(name: attrs[:name]) do |p|
      p.description = attrs[:description]
      p.price       = attrs[:price]
      p.stock_count = attrs[:stock_count]
      p.category    = category
    end
  end
end

puts "Products: #{Product.count}"

# Admin user
admin = User.find_or_create_by!(email: "admin@cosmeticshop.in") do |u|
  u.password = "Admin@123456"
  u.role = :admin
end
puts "Admin: #{admin.email}"
