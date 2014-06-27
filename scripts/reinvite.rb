tel = Tag.find_by(name: "Telecom ParisTech")
us = tel.students.where(provider: nil).lazy.select(&:confirmed_student?).reject{|u| SignupPermission.where(email: u.email).exists?}

us.each do |user|
  puts user.email
  s = SignupPermission.new(email: user.email,
                           school_names: user.schools.map(&:name),
                           firstname: user.firstname,
                           lastname: user.lastname)
  if s.save
    puts "ok"
  else
    puts s.errors.messages
  end
end
