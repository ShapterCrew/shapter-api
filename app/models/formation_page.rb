class FormationPage
  include Mongoid::Document

  field :name
  field :website_url
  field :description
  field :img_url

  field :tag_ids, type: Array

  validates_uniqueness_of :tag_ids
  validates_presence_of :tag_ids

  before_save :tag_ids_to_bson

  class << self
    #array of tags, tag_ids.to_s or tag_ids can be passed
    def find_by_tags(ary)
      a = ary.map do |id|
        if id.is_a?(Tag)
          id.id
        elsif id.is_a? BSON::ObjectId
          id
        elsif id.is_a? String
          BSON::ObjectId.from_string(id)
        else
          raise "find_by_tag: unacceptable type in ary: #{id.class}"
        end
      end
      FormationPage.all_in(tag_ids: a).where(:tag_ids.with_size => a.size).first
    end
  end

  def pretty_id
    id.to_s
  end

  def tags
    Tag.any_in(id: tag_ids)
  end

  def items
    Rails.cache.fetch("frmPgeitms|#{cache_id}|#{tags.max(:updated_at).try(:utc).try(:to_s, :number)}", expires_in: 3.hours) do 
      tags.map(&:items).reduce(:&).uniq
    end
  end

  def students_count
    Rails.cache.fetch("frmPgeStdtsCnt|#{cache_id}|#{Item.any_in(id: items.map(&:id)).max(:updated_at).try(:utc).try(:to_s, :number)}", expires_in: 3.hours) do 
      items.flat_map(&:subscriber_ids).uniq.count
    end
  end

  def sub_formations
    Rails.cache.fetch("frmPgeSbFrmtn|#{cache_id}|#{Tag.max(:updated_at).try(:utc).try(:to_s, :number)}", expires_in: 10.minutes) do 
      c = Category.find_or_create_by(code: "formation")
      Tag.where(category_id: c.id) & items.flat_map(&:tags)
    end
  end

  def comments_count
    items.map(&:comments_count).reduce(:+)
  end

  def diagrams_count
    items.map(&:diagrams_count).reduce(:+)
  end

  def best_comments(n=5)
    Rails.cache.fetch("bestCmmt|#{cache_id}", expires_in: 10.minutes) do 
      self.items
      .select{|i| [i.comments.map(&:author_id) & i.diagrams.map(&:author_id)].any?}
      .select{|i| i.diagrams.count > 1}
      .sort_by{|i| i.avg_diag.values[6]}.reverse
      .take(n)
      .map do |item|
        item.comments
        .sort_by{|c| c.likers_count*(item.diagrams.where(author_id: c.author_id).last.values[6] || 0 rescue 0) }
        .last
      end
      .compact
    end
  end

  private

  def cache_id
    # tags is used instead of tag_ids => passing an id that doesn't match any tag won't alter the cache_id key
    tags.map(&:id).map(&:to_s).join(";")
  end

  def tag_ids_to_bson
    tag_ids.map! do |id|
      id.is_a?(BSON::ObjectId) ? id : BSON::ObjectId.from_string(id)
    end
  end

end
