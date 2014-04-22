File.open("/home/aherve/Downloads/tags.csv").each_line do |line|
  ll = line.chomp.split(",")
  item = Item.new(name: ll.first)
  tags = ll.map do |t|
    Tag.find_or_create_by(name: t)
  end

  item.tags << tags
  item.save
  puts item.name
end
