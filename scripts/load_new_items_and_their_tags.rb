class ItemTag

  def initialize(line)
    @ll = line.chomp.split(";").map(&:strip)
  end

  def item
    @item ||= Item.new(name: @ll.first, tags: tags)
  end

  def tags
    @tags ||= @ll.map{|tagname| Tag.find_or_create_by(name: tagname)}
  end

  def export!
    puts self.to_s if item.save
  end

  def to_s
    "#{item.name} <- #{tags.map(&:name).join(',')}"
  end
end

File.read('./scripts/csvs/new_items_and_their_tags.csv').split("\n").map{|l| ItemTag.new(l)}.each(&:export)
