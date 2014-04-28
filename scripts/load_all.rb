require 'byebug'
Item.delete_all
User.delete_all
Tag.delete_all

@items    = Hash.new
@users    = Hash.new
@tags     = Hash.new
@comments = Hash.new

#Load items and tags
puts "reading items and tags"
File.open("/home/aherve/Shapter/shapter-api/scripts/csvs/items_and_tags.csv").each_line do |line|
  ll = line.chomp.split(";")

  id = ll.first
  name = ll[1]
  tags = ll[1..-1].map do |tagname| 
    @tags[tagname] ||= Tag.new(name: tagname)
  end

  @items[id] = Item.new(name: name, tags: tags)

end

puts "loading users"
File.open("/home/aherve/Shapter/shapter-api/scripts/csvs/users.csv").each_line do |line|
  ll = line.chomp.split(";")

  @users[ll[2]] = User.new(
    firstname: ll[0],
    lastname: ll[1],
    email: ll[2],
    encrypted_password: ll[3],
    items: ll[4..-1].map{|id| @items[id]},
    #schools: [@items[ll[4]]],
    shapter_admin: false,
    confirmed_at: Date.today,
  )
end

puts "loading comments"
File.read('./scripts/csvs/comments.csv').split("##").each do |line|
  ll = line.chomp.split("|")

  @comments[ll.first] = Comment.new(
  content: ll[1].gsub('\"','"').gsub("\'","'"),
  author: @users[ll[2]],
  item: @items[ll[3]],
  )
end

puts "loading likes"
File.open("/home/aherve/Shapter/shapter-api/scripts/csvs/likes.csv").each_line do |line|
  ll = line.chomp.split(";")
  @comments[ll.first].likers << ll[1..-1].map{|email| @users[email]} 
end

puts "loading dislikes"
File.open("/home/aherve/Shapter/shapter-api/scripts/csvs/dislikes.csv").each_line do |line|
  ll = line.chomp.split(";")
  @comments[ll.first].dislikers << ll[1..-1].map{|email| @users[email]}
end

puts "loading quality"
File.open('./scripts/csvs/qualite.csv').each_line do |line|
  ll = line.chomp.split(";")

  c = @comments[ll.first]
  c.quality_score = ll.last.to_i*20
end

puts "loading work"
File.open('./scripts/csvs/qualite.csv').each_line do |line|
  ll = line.chomp.split(";")

  c = @comments[ll.first]
  c.work_score = ll.last.to_i*20
end

puts 'saving tags'
@tags.each{|name,tag| p name ; tag.save(validate: false)}

puts "saving items"
@items.each{|id,item| p id; item.save(validate: false)}

puts "saving users"
@users.each do |email,u|
  u.save(validate: false)
  puts u.email
end

puts "saving comments"
@comments.each{|id,com| com.save(validate: false) ; puts id}
