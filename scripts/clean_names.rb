puts "items"
Item.all.each do |i|
  str = i.name.chomp.strip
  unless str == i.name
    puts str
    i.name = str
    i.save(validate: false)
  end
end

puts "tags"
Tag.all.each do |i|
  str = i.name.chomp.strip
  unless str == i.name
    puts str
    i.name = str
    i.save(validate: false)
  end
end
