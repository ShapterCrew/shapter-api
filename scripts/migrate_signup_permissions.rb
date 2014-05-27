SignupPermission.all.each do |s|
  s.school_names ||= []
  s.school_names << s.school_name
  s.school_names << "Echange #{s.school_name}"
  if s.save
    puts "saved"
  else
    puts s.errors.messages
  end
end
