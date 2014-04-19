module Shapter
  module Helpers
    module FilterHelper

      def filter_items(ary)
        return [] if ary.empty?
        first_tag = Tag.find_by(name: ary.first)
        return [] unless first_tag
        init = first_tag.items
        return init if ary.size == 1
        ary[1..-1].reduce(init) do |aa, tagname|
          aa = aa & Tag.where(name: tagname).flat_map(&:items)
        end
      end

      def reco_tags(ary)
        Tag.all.sample(10)
      end

      private

    end
  end
end
