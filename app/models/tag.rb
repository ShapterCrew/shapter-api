class Tag
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :description, type: String
  field :type, type: String

  field :signup_funnel_tag_list, type: Array

  validates_uniqueness_of :name
  validates_presence_of :name

  #{{{ signup_funnel_tag_list validation

  validate :proper_signup_funnnel_tag_list
  def proper_signup_funnnel_tag_list
    return unless signup_funnel_tag_list
    signup_funnel_tag_list.each.with_index do |h,i|
      if h.is_a? Hash
        errors.add(:field, "signup_funnel_tag_list[#{i}] should have name key") unless h.has_key?("name") or h.has_key?(:name)
        errors.add(:field, "signup_funnel_tag_list[#{i}] should have tag_ids key") unless h.has_key?("tag_ids") or h.has_key?(:tag_ids)
      else
        errors.add(:field, "signup_funnel_tag_list[#{i}] should be a hash")
      end
    end
  end
  #}}}

  # Don't forget to update Tag.merge when adding new relations
  has_and_belongs_to_many :items
  has_and_belongs_to_many :students, class_name: "User", inverse_of: :schools

  def pretty_id
    id.to_s
  end

  class << self
    def touch
      Tag.find_or_create_by(name: "__null__").touch
    end

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
end
