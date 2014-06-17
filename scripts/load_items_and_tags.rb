
File.open(ARGV[0]).each_line do |line|
  ll = line.chomp.split(";").map(&:strip).reject(&:blank?)
  item = Item.new(name: ll.first)
  tags = ll.map do |t|
    Tag.find_or_create_by(name: t)
  end

  #item.tags << tags
  tags.each{|t| item.tags << t}
  if item.save
    puts item.name
  else
    puts item.errors.messages
  end
end
