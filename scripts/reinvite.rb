tel = Tag.find_by(name: "Telecom ParisTech")
us = tel.students.select(&:confirmed_student?).reject{|u| SignupPermission.where(email: u.email).exists?}.reject{|u| u.provider == "facebook"}

us.each do |user|
  puts user.email
  if  SignupPermission.create(email: user.email,
                              school_names: user.schools.map(&:name),
                              firstname: user.firstname,
                              lastname: user.lastname
                             )
                             puts "ok"
  else
    puts "error"
  end
end
