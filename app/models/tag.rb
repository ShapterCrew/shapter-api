class Tag
  include Mongoid::Document
  field :name, type: String

  has_and_belongs_to_many :items

  validates_uniqueness_of :name

  def pretty_id
    id.to_s
  end

end
