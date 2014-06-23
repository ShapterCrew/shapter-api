module Shapter
  module Helpers
    module FilterHelper

      #{{{ filter_items
      # This for v2. 
      def filter_items2(ary)
        Rails.cache.fetch( "filter_items2|#{ary.sort.join(":")}|#{cache_key_for(Tag,Item)}", expires_in: 90.minutes ) do 
          compute_filter(ary)
        end
      end

      def compute_filter(ary)
        return [] if ary.empty?
        first_tag = Tag.find(ary.first)
        return [] unless first_tag
        init = first_tag.items
        return init if ary.size == 1
        ary[1..-1].reduce(init) { |aa, tag_id|
          aa = aa & Tag.where(id: tag_id).flat_map(&:items)
        }.sort_by(&natural_sort)
      end
      #}}}

      #{{{ dictionnary
      # A bit like reco_tags, but simplified. The goal is to build a dictionnary of acceptable tags
      def dictionnary(tagname)
        Rails.cache.fetch( "dico|#{tagname}|#{cache_key_for(Tag,Item)}", expires_in: 90.minutes ) do 
          compute_dico(tagname)
        end
      end

      def compute_dico(tagname)
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
      def reco_tags2(ary,limit)
        Rails.cache.fetch( "reco_tags2|#{ary.sort.join(":")}|#{cache_key_for(Tag,Item)}", expires_in: 90.minutes ) do 
          tags_for_item_ids(
            (items =  Tag.any_in(id: ary) .map(&tag_to_item_ids))
            .reduce(:&)
          )
          .reduce(Hash.new(0)) { |h,t|
            h[t] += 1
            h
          }
          .sort_by{|k,v| v}.reverse
          .reject{|tag,count| count >= items.size}
          .reject{|tag,count| ary.include? tag.id.to_s}
          .reject{|tag,count| (tag.type || "").downcase == "cours"}
        end.take(limit)
        .map{|tag,count| {name: tag.name, id: tag.pretty_id, score: count, type: tag.type, short_name: tag.short_name}}
      end
      #}}}

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

      def cache_key_for(*args)
        args.sort_by(&:to_s).map { |klass|
          [
            #klass.to_s,
            klass.max(:updated_at).try(:utc).try(:to_s, :number)
          ].join(":")
        }
        .join("|")
      end

      def natural_sort
        Proc.new do |item|
          item.name
          .downcase
          .gsub("/àÀáÁãÃâÂäÄ/","a")
          .gsub("/éÉèÈêÊẽẼëË/",'e')
        end
      end

    end
  end
end
