puts "enter school name"
school_name = $stdin.gets.chomp.strip

puts "enter echange school name"
echange_name = $stdin.gets.chomp.strip

if echange_name != ""
  school_names = [school_name,echange_name]
else
  school_names = [school_name]
end


File.open(ARGV[0]).each_line do |line|
  email = line.chomp.downcase
  full_name = email.split("@")[0]
  first_name = full_name.split(".")[0].capitalize
  last_name = full_name.split(".")[1].capitalize

  s = SignupPermission.new(
    email: email,
    #school_name: school_name, #v3 compatibility # ya plus
    school_names: school_names, #v4 compatibility
    firstname: first_name,
    lastname: last_name,
  )

  # j'aime bien afficher les erreurs quand il y en a
  if s.save
    puts "#{email} saved"
  else
    puts "pb with #{email}: #{s.errors.messages}"
  end


end
