require 'byebug'
@items = Hash.new
@comments = Hash.new
File.open("/home/aherve/Shapter/shapter-api/scripts/csvs/items_and_tags.csv").each_line do |line|
  ll = line.chomp.split(";").map(&:strip)

  id = ll[0]
  name = ll[1]

  @items[id] = Item.find_by(name: name)
end

puts "#{@items.size} item ids loaded"


File.read('./scripts/csvs/comments.csv').split("##").each do |line|
  ll = line.chomp.split("|").map(&:strip)

  #content = ll[1].gsub('\"','"').gsub("\'","'")
  author_email = ll[2]
  item = @items[ll[3]]

  @comments[ll[0]] = item.comments.find_by(author: User.find_by(email: author_email))

end

puts "#{@comments.size} comments"

File.open('./scripts/csvs/travail.csv').each_line do |line|
  ll = line.chomp.split(";").map(&:strip)

  c = @comments[ll.first]
  if c
    c.work_score = ll.last.to_i*20
    c.save
    puts c.id.to_s
  end
end
