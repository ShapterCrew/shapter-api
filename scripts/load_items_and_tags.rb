
File.open(ARGV[0]).each_line do |line|
  ll = line.chomp.split(",").map(&:strip).reject(&:blank?)
  item = Item.find_or_create_by(name: ll.first)
  tags = ll.map do |t|
    Tag.find_or_create_by(name: t)
  end

  item.tags << tags
  item.save
  puts item.name
end
