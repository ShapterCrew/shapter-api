Item.all.flat_map(&:comments).select{|c| c.alien?}.each do |comment|
  puts "ERROR!!!" unless comment.update_attribute(:context, "exchange") 
end
