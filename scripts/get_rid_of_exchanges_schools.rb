# Will get rid of exchanges schools

@sch = Category.find_by(code: "school")

@true_school = Hash.new do |h,k|
  h[k] = Tag.find_or_create_by(name: k.split(" ").last.strip)
end

echs = [
  "Echange Eurecom",
  "Echange Ponts ParisTech",
  "Echange Supélec",
  "Echange Telecom ParisTech",
  "Echange ULM",
  "Échange ENSAE",
  "Échange ESPCI",
].map{|name| Tag.find_by(name: name)}.compact

echs.each{|e| e.update_attributes(category_id: @sch.id)}
echs.each{|e| @true_school[e.name].update_attributes(category_id: @sch.id)}

echs.each do |ech|
  puts ech.name

  ech.items.each do |item|
    if (ts = item.tags.where(category_id: @sch.id)).count == 1
      puts "item #{item.name} has school #{ts.map(&:name)} and should have school #{@true_school[ts.first.name]}"
      item.tags << (ss = @true_school[ts.first.name])
      if item.save and ss.save
        puts "done"
      else
        puts "!!!!!!!!!!ERROR!!!!!!!!!!"
      end
    end
  end
end


echs.each do |ech|
  ech.destroy
end
