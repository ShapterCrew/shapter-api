#Léon, nettoyeur

puts "---------cleaning items---------"
Item.all.each do |item|
  item.tags.each do |tag|
    unless tag.items.include? item
      puts "adding item #{item.name} to tag #{tag.name}"
      tag.items << item ; tag.save ; item.save
    end
  end
end

puts "---------cleaning tags---------"
Tag.all.each do |tag|
  tag.items.each do |item|
    unless item.tags.include? tag
      puts "adding tag #{tag.name} to item #{item.name}"
      item.tags << tag ; item.save ; tag.save
    end
  end
end

