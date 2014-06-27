File.open("./lost.dat",'w') do |f|
  User.where(provider: "facebook").where(email: /\Afake\./).where(schools: nil).each do |user|
    f.puts [user.name, user.email].join("\t")
  end
end
