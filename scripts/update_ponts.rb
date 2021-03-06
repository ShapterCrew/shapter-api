'class ItemUpdater
  attr_accessor :ll
  def initialize(line)
    @ll = line.chomp.split("\t").map(&:strip).compact
  end

  def name
    [ll[0],ll[1]].join(" - ")
  end

  def tags
    @tags ||= @ll.reject{|name| name.blank?}.map{|name| Tag.find_or_create_by(name: name)}
  end

end
'

not_found = []
saved     = []
errored   = []

File.read(ARGV[0]).each_line do |line|
  ll = line.chomp.split(';').map(&:strip).reject(&:blank?)
  item_name = ll.first
  new_name = [ll[1],ll[0]].join(" - ")

  if item = Item.find_by(name: item_name)
    puts "items found : #{item_name}, new name : #{new_name}"
    puts item.name
    if item.update_attribute(:name, new_name)
      saved << new_name 
    else
      errored << new_name
    end
  else
    puts "items NOT found : #{item_name}"
    not_found << new_name 
  end
end

puts "not found: "
puts not_found
puts not_found.count
puts "errored: "
puts errored
puts errored.count
puts "saved: #{saved.count}"


'File.read(ARGV[0]).each_line.map{|line| ItemUpdater.new(line)}.each do |item_up|

  if item = Item.find_by(name: item_up.name)
    #item_up.tags.each{|t| item.tags.delete(t)}
    item_up.tags.each{|t| item.tags << t}
    puts r = if item.save and item_up.tags.map(&:save).reduce(:&)
               "saved:\titem #{item_up.name}"
             else
               "ERROR:\t#{item.errors.messages}" + item_up.tags.map{|t| t.errors.messages}.compact
             end
  else
    puts "ERROR:\titem #{item_up.name}\tNOT FOUND."
  end

end
  '
