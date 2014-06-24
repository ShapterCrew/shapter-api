def remove_sa name
  temp = name.split("Statistique et apprentissage")
  new = temp[0]+"sa"+temp[1]
  return new
end



def remove_sa! item
  new_name = remove_sa item.name
  puts "old name : #{item.name}"
  puts "new name : #{new_name}"
  puts "save? (y)"
  response = $stdin.gets.chomp.strip
  if response == "y"
    item.name = new_name
    tag = Tag.find_or_create_by(name: new_name)
    tag.save
    item.tags << tag
    item.save
 end
end

