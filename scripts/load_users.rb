class UserLine
  def initialize(line)
    @ll = line.chomp.split(";")
  end

  def firstname
    @ll[0]
  end

  def lastname
    @ll[1]
  end

  def email
    @ll[2]
  end

  def password_hash
    @ll[3]
  end

  def items
    @ll[4..-1].map{|name| Item.find_by(name: name)}
  end

  def to_user
    User.new(
      firstname: firstname,
      lastname: lastname,
      email: email,
      shapter_admin: false,
      encrypted_password: password_hash,
      confirmed_at: Date.today,
      items: items,
    )
  end

end

File.open("/home/aherve/Downloads/users.csv").each_line do |line|
  u = UserLine.new(line).to_user
  u.save(validate: false)
  puts u.email
end
