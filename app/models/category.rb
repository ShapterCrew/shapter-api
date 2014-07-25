class Category
  include Mongoid::Document

  field :code
  has_many :tags

  def pretty_id
    id.to_s
  end
end
