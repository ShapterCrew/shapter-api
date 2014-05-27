sanitize = lambda do |string| 
  string.downcase.gsub(/[éèêẽëÉÈ]/,"e").gsub(/[ÀÁàáãäâ]/,"a").gsub("ï","i")
end

def email(ary)
  "#{ary.first}.#{ary.last}@telecom-paristech.fr"
end

create_perm = lambda do |line| 
  fname,lname = line.split("\t").map(&:strip)
  return nil if (!fname or !lname)

  mail = email([fname,lname].map(&sanitize))
  return nil if SignupPermission.where(email: mail).exists?

  s = SignupPermission.new(
    email: mail,
    school_name: "Telecom ParisTech", #v3 compatibility
    school_names: ["Telecom ParisTech","Echange Telecom ParisTech"], #v4 compatibility
    firstname: fname,
    lastname: lname,
  )
  puts s.email
  return s
end


File.read(ARGV[0]).split("\n").map(&:chomp).map(&create_perm).compact.each(&:save)
