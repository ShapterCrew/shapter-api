#Léon, nettoyeur

Item.each do |item|
  item.tags.each do |tag|
    tag.reload
    unless tag.items.include? item
      puts "adding item #{item.name} to tag #{tag.name}"
      tag.items << item ; tag.save ; item.save
    end
  end
end

Tag.each do |tag|
  tag.items.each do |item|
    item.reload
    unless item.tags.include? tag
      puts "adding tag #{tag.name} to item #{item.name}"
      item.tags << tag ; item.save ; tag.save
    end
  end
end
