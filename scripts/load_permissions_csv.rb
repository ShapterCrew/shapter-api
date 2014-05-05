# Create new signup permissions. The input file is not validated, it MUST be of the format: 
# email <tab> school_name

if ARGV.empty?
  puts "please pass a csv file as argument"
  exit
end

File.open(ARGV[0]).each_line do |line|
  email, school_name = line.chomp.split("\t").map(&:strip)
  puts email if SignupPermission.find_or_create_by(email: email, school_name: school_name)
end
