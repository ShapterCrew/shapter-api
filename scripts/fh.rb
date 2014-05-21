#is = Tag.find_by(name: "Formation Humaine").items
#
#File.open("restore_tags.csv","w") do |f|
#  is.each do |item|
#    f.puts [item.name.strip, item.tags.map(&:name)].join("\t")
#  end
#end
#
#File.open("restore_subscribers.csv","w") do |f|
#  is.each do |item|
#    f.puts [item.name.strip, item.subscribers.map(&:email)].join("\t")
#  end
#end
#
#File.open("restore_interested_users.csv","w") do |f|
#  is.each do |item|
#    f.puts [item.name.strip, item.interested_users.map(&:email)].join("\t")
#  end
#end
#
#File.open("restore_comments.csv","w") do |f|
#  is.each do |item|
#    item.comments.each do |comm|
#      f.puts [item.name, comm.author.email,comm.content].join("\t")+"||"
#    end
#  end
#end
#

###############################################################

@item = {}
@comments = []
File.open("./restore_tags.csv").each_line do |line|
  ll = line.split("\t")
  name = ll.first
  tags = ll[1..-1].map{|n| Tag.find_or_create_by(name: n)}
  @item[name] = Item.new(name: name, tags: tags)
end

File.open("./restore_subscribers.csv").each_line do |line|
  ll = line.split("\t")
  name = ll.first
  subscribers = ll[1..-1].map{|email| User.find_by(email: email)}

  subscribers.each{|s| @item[name].subscribers << s}
end

File.open("./restore_interested_users.csv").each_line do |line|
  ll = line.split("\t")
  name = ll.first
  interested_users = ll[1..-1].map{|email| User.find_by(email: email)}

  interested_users.each{|s| @item[name].subscribers << s}
end

File.read("./restore_comments.csv").split("||").each do |comm|
  ll = comm.chomp.split("\t").map(&:strip)
  name = ll.first
  next unless name
  u = User.find_by(email: ll[1])
  content = ll[2]
  @comments << Comment.new(author: u, content: content, item: @item[name]) 
end

@item.each do |k,v|
  puts v.save
end

@comments.each do |v|
  puts v.save
end
