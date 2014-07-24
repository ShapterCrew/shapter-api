class Category
  include Mongoid::Document

  field :code
  has_many :tags
end
