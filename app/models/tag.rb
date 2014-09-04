class Tag
  include Mongoid::Document
  include Mongoid::Timestamps

  include Funnelable
  funnel_for :signup_funnel
  funnel_for :constructor_funnel # ZBRA !

  field :name, type: String
  field :short_name, type: String
  field :type, type: String

  field :custom_diag_dims, type: Array

  belongs_to :category

  #validates_uniqueness_of :name
  validate :type_name_uniqueness
  validate :custom_diag_dims_validator
  validates_presence_of :name

  # Don't forget to update Tag.merge when adding new relations
  has_and_belongs_to_many :items
  has_and_belongs_to_many :students, class_name: "User", inverse_of: :schools

  def pretty_id
    id.to_s
  end

  def category_code
    category ? category.code : :other
  end

  scope :schools, -> { where(category_id: Category.find_or_create_by(code: :school)) }

  def cached_students
    Rails.cache.fetch("tagStudents|#{id}|#{updated_at.try(:utc).try(:to_s,:number)}",expires_in: 3.hours) do
      students
    end
  end

  def students_count
    student_ids.size
  end

  def items_count
    item_ids.size
  end

  def diagrams_count
    Rails.cache.fetch("tagDiagCnt|#{id}|#{items.max(:updated_at).try(:utc).try(:to_s,:number)}",expires_in: 3.hours) do
      items.flat_map(&:diagrams).compact.count
    end
  end

  def comments_count
    Rails.cache.fetch("tagCommCnt|#{id}|#{items.max(:updated_at).try(:utc).try(:to_s,:number)}",expires_in: 3.hours) do
      items.flat_map(&:comments).compact.count
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

  protected

  def type_name_uniqueness
    errors.add(:base, "name/type already taken") if Tag.where(category_id: category_id, name: name).not.where(id: id).exists?
  end

  def custom_diag_dims_validator
    errors.add(:base, "custom diags dimensions should have an odd number of values") if !custom_diag_dims.blank? and custom_diag_dims.size.even? and custom_diag_dims.size > 1
  end
end
