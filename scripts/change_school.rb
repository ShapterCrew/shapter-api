puts "enter email"
email = gets.chomp.strip
puts "enter school name"
school_name = gets.chomp.strip

puts "will changed '#{email}' for new school: '#{school_name}'. Validate ? (y/n)"
valid = gets.chomp.strip
exit unless valid == "y"

if s = SignupPermission.find_by(email: email)
  s.school_name = school_name
  puts "signup permission saved" if s.save
else
  puts "no signup permission found"
end

if u = User.find_by(email: email)
  if tag = Tag.find_by(name: school_name)
    u.schools = [tag]
    puts "user found and saved " if u.save
  else
    puts "error: tag not found"
  end
else
  puts "no user found"
end
