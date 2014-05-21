telecom = Tag.find_by(name: "Telecom ParisTech")

File.open(ARGV[0]).each_line do |line|
  ll = line.chomp.split(";").map(&:strip)

  item_name = ll[0]
  email = ll[1]
  codage, maths, theorique, charge_travail, qualite = ll[2..6].map(&:to_i)

  if i = telecom.items.find_by(name: item_name) and u = User.find_by(email: email)
    i.diagrams << Diagram.new(
      item: i,
      author: u,
      values: [charge_travail,nil,maths,codage,theorique,nil,qualite,nil,nil,nil],
    )
    puts item_name if i.save
  else
    puts "!!! warning : didn't found itemxuser:  #{item_name}, #{email}"
  end
end
