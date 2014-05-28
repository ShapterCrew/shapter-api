class ItemUpdater
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

File.read(ARGV[0]).each_line.map{|line| ItemUpdater.new(line)}.each do |item_up|

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
