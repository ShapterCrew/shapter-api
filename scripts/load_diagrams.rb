telecom = Tag.find_by(name: "Telecom ParisTech")

File.open(ARGV[0]).each_line do |line|
  ll = line.chomp.split(";").map(&:strip)

  item_name = ll[0]
  email = ll[1]
  groupe,codage, maths, theorique, charge_travail, qualite = ll[2..7].map{|s| s == "None" ? nil : s.to_i}

  if i = telecom.items.find_by(name: item_name) and u = User.find_by(email: email)

    #i.diagrams << Diagram.new(
    #  item: i,
    #  author: u,
    #  values: [charge_travail,nil,maths,codage,theorique,nil,qualite,nil,nil,nil],
    #)

    d = i.diagrams.find_or_create_by(author: u)
    d.values = [charge_travail,groupe,maths,codage,theorique,nil,qualite,nil,nil,nil]
    puts item_name if d.save
  else
    puts "!!! warning : didn't found item x user:  #{item_name}, #{email}"
  end
end
