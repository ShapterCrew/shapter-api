#Léon, nettoyeur

puts "---------ITEMS/TAGS---------"

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

puts "---------TAGS/STUDENTS---------"

puts "---------cleaning students---------"
User.all.each do |student|
  student.schools.each do |tag|
    unless tag.students.include? student
      print "attempting to add student\t#{student.name}\tto tag\t#{tag.name}..."
      tag.students << student 
      if tag.save and student.save
        print "...success\n"
      else
        print "... FAILURE !!!!!!!!!!!!\n"
      end
    end
  end
end

puts "---------cleaning tags---------"
Tag.all.each do |tag|
  tag.students.each do |student|
    unless student.schools.include? tag
      print "attempting to add tag\t#{tag.name}\tto student\t#{student.name}..."
      student.schools << tag 
      if student.save and tag.save
        print "...success\n"
      else
        print "... FAILURE !!!!!!!!!!!!\n"
      end
    end
  end
end

