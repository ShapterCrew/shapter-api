class Tag
  include Mongoid::Document
  include Mongoid::Timestamps

  include SchoolStuff

  include Funnelable
  funnel_for :signup_funnel
  funnel_for :constructor_funnel # ZBRA !

  field :name, type: String
  field :short_name, type: String
  field :type, type: String

  belongs_to :category


  #validates_uniqueness_of :name
  validate :type_name_uniqueness
  validates_presence_of :name

  # Don't forget to update Tag.merge when adding new relations
  has_and_belongs_to_many :items
  has_and_belongs_to_many :students, class_name: "User", inverse_of: :schools

  def pretty_id
    id.to_s
  end

  def cached_students
    Rails.cache.fetch("tagStudents|#{id}|#{updated_at.try(:utc).try(:to_s,:number)}",expires_in: 3.hours) do
      students
    end
  end

  class << self
    def touch
      Tag.find_or_create_by(name: "__null__").touch
    end

    # merge tag t2 into tag t1. Tag t2 will be destroyed
    def merge!(t1,t2)
      is = []
      ss = []
      t2.items.each{|i| t1.items << i; i.tags << t1 ; is << i}
      t2.students.each{|s| t1.students << s; s.schools << t1 ; ss << s}
      if [t1.save,ss.map(&:save),is.map(&:save)].reduce(:&)
        t2.destroy
        true
      else
        false
      end
    end

  end

  after_destroy :class_touch
  def class_touch
    Tag.touch
  end

  def best_comments(n=5)
    Rails.cache.fetch("bestCmmt|#{id}", expires_in: 10.minutes) do 
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

  protected

  def type_name_uniqueness
    errors.add(:base, "name/type already taken") if Tag.where(category_id: category_id, name: name).not.where(id: id).exists?
  end

end
