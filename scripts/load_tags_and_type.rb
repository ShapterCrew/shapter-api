
File.open(ARGV[0]).each_line do |line|
  ll = line.chomp.split(";").map(&:strip).reject(&:blank?)
  tag = Tag.find_or_create_by(name: ll.first)
  type = ll.second

  tag.type = type
  if tag.save
    puts "tag : #{tag.name}, type : #{type}"
  else
    puts "pb with : #{tag.name}, error : #{tag.errors.messages}"
  end
end
