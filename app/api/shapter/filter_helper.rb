module Shapter
  module FilterHelper

    def filter_items(ary)
      return [] if ary.empty?
      init = (Tag.find_by(name: ary.first).items.to_a rescue [])
      return init if ary.size == 1
      ary[1..-1].reduce(init) do |aa, tagname|
        aa = aa & (Tag.find_by(name: tagname).items.to_a rescue [])
      end
    end
  end
end
