# Boris est un peu violent et pas très poli, mais c'est un bon travailleur

Item.each do |item|
  item.comments.where(content: "").delete_all
  puts "#{item.name}: save => #{item.save}"
end
