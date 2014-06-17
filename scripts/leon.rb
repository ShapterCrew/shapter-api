#Léon, nettoyeur

puts "---------cleaning items---------"
Item.all.each do |item|
  item.tags.each do |tag|
    unless tag.items.include? item
      print "attempting to add item\t#{item.name}\tto tag\t#{tag.name}..."
      tag.items << item 
      if tag.save and item.save
        print "...success\n"
      else
        print "... FAILURE !!!!!!!!!!!!\n"
      end
    end
  end
end

puts "---------cleaning tags---------"
Tag.all.each do |tag|
  tag.items.each do |item|
    unless item.tags.include? tag
      print "attempting to add tag\t#{tag.name}\tto item\t#{item.name}..."
      item.tags << tag 
      if item.save and tag.save
        print "...success\n"
      else
        print "... FAILURE !!!!!!!!!!!!\n"
      end
    end
  end
end

