#Léon, nettoyeur

puts "---------cleaning tags---------"
Tag.all.each do |tag|
  puts tag.name
  tag.items.each do |item|
    item.reload
    unless item.tags.include? tag
      puts "adding tag #{tag.name} to item #{item.name}"
      item.tags << tag ; item.save ; tag.save
    end
  end
end

puts "---------cleaning items---------"
Item.all.each do |item|
  puts item.name
  item.tags.each do |tag|
    tag.reload
    unless tag.items.include? item
      puts "adding item #{item.name} to tag #{tag.name}"
      tag.items << item ; tag.save ; item.save
    end
  end
end

