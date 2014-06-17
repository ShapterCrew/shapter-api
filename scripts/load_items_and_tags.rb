
File.open(ARGV[0]).each_line do |line|
  ll = line.chomp.split(";").map(&:strip).reject(&:blank?)
  item = Item.new(name: ll.first)
  tags = ll.map do |t|
    Tag.find_or_create_by(name: t)
  end

  tags.each{|t| item.tags << t ; t.items << item}
  if item.save and tag.map(&:save).reduce(:&)
    puts item.name
  else
    puts item.errors.messages
    puts tags.map(&:errors).map(&:messages)
  end
end
