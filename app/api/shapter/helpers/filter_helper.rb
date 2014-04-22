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

      def reco_tags(ary,limit)
        tags_for_item_ids(
          Tag.any_in(name: ary).flat_map(&tag_to_item_ids).uniq.compact
        )
        .reduce(Hash.new(0),&reco_reduce)
        .sort_by{|k,v| v}.reverse
        .reject{|name,count| ary.include? name}
        .take(limit)
      end

      private

      def db
        @db ||= Mongoid::Sessions.default
      end

      def tags_for_item_ids(ary_of_item_ids)
        Item.any_in(:id => ary_of_item_ids).flat_map(&:tags)
      end

      def tag_to_item_ids
        -> t {
          db[:tags].find("_id" => t.id).select(item_ids: 1).map{|h| h["item_ids"]}.flatten
        }
      end

      def reco_reduce
        Proc.new do |h,tag|
          h[tag.name] += 1
          h
        end
      end

    end
  end
end
