
def double_first_name user
  email = user.email
  puts "email : #{email}"
  full_name = email.split("@")[0]
  puts "full name : #{full_name}"
  first_name = full_name.split(".")[0].capitalize
  last_name = full_name.split(".")[1].capitalize
  puts "first name : #{first_name}"
  puts "last name : #{last_name}"
  puts "save ? (y)"
  response = $stdin.gets.chomp.strip
  if response == 'y'
    user.firstname = first_name
    user.lastname = last_name
    if user.save
      puts "#{email} saved"
    else
      puts "pb with #{email}: #{user.errors.messages}"
    end

  end
end

