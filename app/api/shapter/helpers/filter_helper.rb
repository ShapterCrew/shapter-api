module Shapter
  module Helpers
    module FilterHelper

      #{{{ filter_items
      # This for v2. 
      def filter_items2(ary)
        Rails.cache.fetch( "filterItem|#{ary.sort.join(":")}|#{cache_key_for(Tag,Item)}", expires_in: 90.minutes ) do 
          compute_filter(ary).sort_by(&natural_sort)
        end
      end

      def quality_filter(ary)
        Rails.cache.fetch( "qualityFilter|#{ary.sort.join(":")}|#{cache_key_for(Tag,Item)}", expires_in: 90.minutes ) do 
          compute_filter(ary).sort_by(&quality_sort).reverse
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
        }
      end
      #}}}

      #{{{ dictionnary
      # A bit like reco_tags, but simplified. The goal is to build a dictionnary of acceptable tags
      def dictionnary(tag_id)
        Rails.cache.fetch( "dico|#{tag_id}|#{cache_key_for(Tag,Item)}", expires_in: 90.minutes ) do 
          compute_dico(tag_id)
        end
      end

      def compute_dico(tag_id)
        t = Tag.where(id: tag_id)
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
            (items =  Tag.any_in(id: ary).map(&tag_to_item_ids).reduce(:&) )
          )
          .reduce(Hash.new(0)) { |h,t|
            h[t] += 1
            h
          }
          .sort_by{|k,v| v}.reverse
          .reject{|tag,count| count >= items.count}
          .reject{|tag,count| ary.include? tag.id.to_s}
          .reject{|tag,count| (tag.type || "").downcase == "cours"}
        end.take(limit)
        .map{|tag,count| {name: tag.name, id: tag.pretty_id, score: count, category: tag.category_code, short_name: tag.short_name}}
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
          .gsub(/[à|À|á|Á|ã|Ã|â|Â|ä|Ä]/,"a")
          .gsub(/[é|É|è|È|ê|Ê|ẽ|Ẽ|ë|Ë]/,'e')
        end
      end

      def quality_sort
        Proc.new do |item|
          item.avg_diag.values[6].to_i
        end
      end

    end
  end
end
