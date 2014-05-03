module Shapter
  module Helpers
    module FilterHelper

      #{{{ filter_items
      # This was for v1. It is to be deprecated
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

      # This for v2. 
      def filter_items2(ary)
        return [] if ary.empty?
        first_tag = Tag.find(ary.first)
        return [] unless first_tag
        init = first_tag.items
        return init if ary.size == 1
        ary[1..-1].reduce(init) do |aa, tag_id|
          aa = aa & Tag.where(id: tag_id).flat_map(&:items)
        end
      end
      #}}}

      #{{{ dictionnary
      # A bit like reco_tags, but simplified. The goal is to build a dictionnary of acceptable tags
      def dictionnary(tagname)
        t = Tag.where(name: tagname)
        return [] if t.empty?
        tags_for_item_ids(
          t
          .flat_map(&tag_to_item_ids)
          .uniq
        )
        .uniq
      end
      #}}}

      #{{{ reco_tags
      # Recommend a list of tags, based on a tag list.
      # Collaborative filtering based on tag->item->tag path
      def reco_tags(ary,limit)
        tags_for_item_ids(
          Tag.any_in(name: ary)
          .map(&tag_to_item_ids)
          .reduce(:&)
        )
        .reduce(Hash.new(0),&reco_reduce)
        .sort_by{|k,v| v}.reverse
        .reject{|name,count| count < 2 }
        .reject{|name,count| ary.include? name}
        .take(limit)
        .map{|name,count| {name: name, score: count}}
      end

      def reco_tags2(ary,limit)
        tags_for_item_ids(
          Tag.any_in(id: ary)
          .map(&tag_to_item_ids)
          .reduce(:&)
        )
        .reduce(Hash.new(0),&reco_reduce)
        .sort_by{|k,v| v}.reverse
        .reject{|name,count| count < 2 }
        .reject{|name,count| ary.include? name}
        .take(limit)
        .map{|name,count| {name: name, score: count}}
      end
      #}}}

      # Collaborative filtering items -> users -> items
      # This seriously needs to be refactored, this version is way too ugly
      def reco_item(user,limit,exclude)
        user_item_ids = db[:users].find("_id" => user.id).select(item_ids: 1).map{|h| h["item_ids"]}.flatten.compact
        user_items_user_ids = user_item_ids.flat_map{|item_id|
          db[:items].find("_id" => item_id).select(subscriber_ids: 1).map{|h| h["subscriber_ids"]}
        }.flatten.compact
        user_items_users_item_ids = user_items_user_ids.flat_map{|user_id|
          db[:users].find("_id" => user_id).select(item_ids: 1).map{|h| h["item_ids"]}
        }.flatten.flatten
        .reject{|item_id| user.item_ids.include? item_id}
        .reject{|item_id| exclude.include? item_id.to_s}
        .reduce(Hash.new(0)){|h,item_id|
          h[item_id] += 1
          h
        }
        .sort_by{|item_id,count| count}.reverse
        .map(&:first)
        .take(limit)
        .map{|id| Item.find(id)}
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
