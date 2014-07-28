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
    tags.flat_map(&:items).uniq
  end

  def students
    items.flat_map(&:subscribers).uniq
  end

  def students_count
    students.count
  end

  def comments_count
    items.map(&:comments_count).reduce(:+)
  end

  def diagrams_count
    items.map(&:diagrams_count).reduce(:+)
  end

  def best_comments(n=5)
    Rails.cache.fetch("bestCmmt|#{tag_ids}", expires_in: 10.minutes) do 
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
    tag_ids.map(&:to_s).join(";")
  end

  def tag_ids_to_bson
    tag_ids.map! do |id|
      id.is_a?(BSON::ObjectId) ? id : BSON::ObjectId.from_string(id)
    end
  end
end
