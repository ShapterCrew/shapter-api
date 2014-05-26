
telecom = Tag.find_by(name: "Telecom ParisTech")
eurecom = Tag.find_by(name: "Eurecom")

File.open("/home/aherve/Desktop/nainAEurecom.csv").each_line do |line|
  fname,lname = line.chomp.split("\t").map(&:strip)
  email = "#{fname.downcase}.#{lname.downcase}@telecom-paristech.fr"
  s = SignupPermission.find_or_create_by(email: email)
  u = User.find_by(email: email)

  if s
    s.school_name = "Eurecom"
    puts s.save
  end

  if u
    u.schools.delete(telecom)
    u.schools << eurecom
    puts u.save
    telecom.students.delete(u)
    telecom.save
  end


end
