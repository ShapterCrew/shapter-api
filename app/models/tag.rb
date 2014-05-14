class Tag
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String

  has_and_belongs_to_many :items

  validates_uniqueness_of :name

  has_and_belongs_to_many :students, class_name: "User", inverse_of: :schools

  def pretty_id
    id.to_s
  end

  class << self
    def touch
      Tag.find_or_create_by(name: "__null__").touch
    end
  end

  after_destroy :class_touch
  def class_touch
    Tag.touch
  end
end
