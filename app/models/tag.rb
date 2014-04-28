class Tag
  include Mongoid::Document
  field :name, type: String

  has_and_belongs_to_many :items, dependent: :destroy

  validates_uniqueness_of :name

  has_and_belongs_to_many :students, class_name: "User", inverse_of: :schools

  def pretty_id
    id.to_s
  end

end
