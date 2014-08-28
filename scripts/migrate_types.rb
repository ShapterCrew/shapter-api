c = Category.find_or_create_by(code: "school")

Tag.all.select{|t| t.students.count > 0}.each do |tag|
  tag.update_attribute(:category_id, c.id)
end

def type_to_cat!(type,cat)
  puts "#{type} => #{cat}"
  Tag.where(type: type).lazy.each do |tag|
    puts "!!!!!!!ERROR!!!!!!" unless tag.update_attribute(:category_id , Category.find_or_create_by(code: cat).id)
  end
end

h = {
  "Année"              => "admin",
  "Approfondissement"  => "option",
  "Autre"              => "other",
  "Cours"              => "item_name",
  "Crédit"             => "credits",
  "Crédits"            => "credits",
  "Créneau"            => "admin",
  "Cursus IMI"         => "option",
  "Domaine"            => "department",
  "Département"        => "department",
  "Electif"            => "choice",
  "Filière SEGF"       => "option",
  "Formation"          => "formation",
  "Horaire"            => "admin",
  "Jour"               => "admin",
  "Langue"             => "language",
  "Localisation"       => "geo",
  "Master"             => "formation",
  "Masters"            => "formation",
  "Mastère Spécialisé" => "formation",
  "Module GCC"         => "option",
  "Métier"             => "option",
  "Option"             => "option",
  "Ouverture"          => "other",
  "Parcours"           => "option",
  "Parcours VET"       => "option",
  "Professeur"         => "teacher",
  "Période"            => "admin",
  "Semestre"           => "admin",
  "Statut Elève"       => "admin",
  "Thème"              => "other",
  "Tronc commun"       => "formation",
  "Volume horaire"     => "admin",
  "choix"              => "choice",
  "cours"              => "item_name",
  "niveau"             => "admin",
  "obligatoire"        => "choice",
  "École"              => "school",
  "Établissement"      => "school",
}

h.each_pair{|t,c| type_to_cat!(t,c)}

other = Category.find_or_create_by(code: "other")

Tag.where(category_id: nil).each{|t| puts t.update_attribute(:category_id , other.id)}
Tag.where(category_id: "" ).each{|t| puts t.update_attribute(:category_id , other.id)}
