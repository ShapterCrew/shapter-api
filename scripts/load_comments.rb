@coms = Hash.new

File.read('./scripts/csvs/comments.csv').split("##").each do |line|
  ll = line.chomp.split("|")

  @coms[ll.first] ||= Hash.new
  h = @coms[ll.first]

  h[:content] = ll[1].gsub('\"','"').gsub("\'","'")
  h[:author] = User.find_by(email: ll[2])
  h[:item] = Item.find_by(name: ll[3])
end
puts "comment content: #{@coms.size} comments loaded"

File.open('./scripts/csvs/qualite.csv').each_line do |line|
  ll = line.chomp.split(";")
  @coms[ll.first] ||= Hash.new
  h =@coms[ll.first] 
  h[:quality_score] = ll.last.to_i*20
end

puts "quality loaded"

File.open('./scripts/csvs/travail.csv').each_line do |line|
  ll = line.chomp.split(";")
  @coms[ll.first] ||= Hash.new
  h =@coms[ll.first] 
  h[:work_score] = ll.last.to_i*20
end

puts "work loaded"

File.open('./scripts/csvs/likes.csv').each_line do |line|
  ll = line.chomp.split(";")
  @coms[ll.first] ||= Hash.new
  h = @coms[ll.first] 
  h[:likers] = ll[1..-1].map{|email| User.find_by(email: email)}
end

File.open('./scripts/csvs/dislikes.csv').each_line do |line|
  ll = line.chomp.split(";")
  @coms[ll.first] ||= Hash.new
  h = @coms[ll.first] 
  h[:dislikers] = ll[1..-1].map{|email| User.find_by(email: email)}
end

puts "work loaded"

@coms.values.each_with_index do |h,i|
  c = Comment.new(h)
  c.save(validate: false) unless c.item.nil?
  puts i
end
