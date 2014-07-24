c = Category.find_or_create_by(code: "school")

Tag.all.select{|t| t.students.count > 0}.each do |tag|
  tag.update_attribute(:category_id, c.id)
end
