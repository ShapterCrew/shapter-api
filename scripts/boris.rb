# Boris est un peu violent et pas très poli, mais c'est un bon travailleur

if Rails.env.production?
  "Boris not work in prod. Boris too violent, they said.j"
  exit
end

Item.each do |item|
  item.comments.where(content: "").delete_all
  item.save
end

Item.all.lazy.each{|i| i.destroy unless i.valid?; i.comments.each{|c| c.destroy unless c.valid?}}
Tag.all.lazy.each{|i| i.destroy unless i.valid?}
User.all.lazy.each{|i| i.destroy unless i.valid?}
