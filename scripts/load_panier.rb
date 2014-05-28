File.read("./panier.csv").each_line do |line|
  ll = line.chomp.split(";").map(&:strip)
  if u = User.find_by(email: ll.first) and i = Item.find_by(name: ll.last)
    unless u.items.include? i
      u.cart_items << i ; u.save ; i.save
      puts "SAVED:\t#{ll}"
    else
      puts "SKIPPED:\t#{ll}"
    end
  else puts "NOT FOUND : \t#{ll}"
  end
end
