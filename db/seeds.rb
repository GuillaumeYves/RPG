Dir[File.join(Rails.root, "db", "seeds", "*.rb")].sort.each do |seed|
  puts "Seeding..."
  load seed
  puts "Seeding complete."
end
