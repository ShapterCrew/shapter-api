class Item
  include Mongoid::Document
  field :name, type: String
  field :description, type: String

  embeds_many :comments

  has_and_belongs_to_many :likers, class_name: "User", inverse_of: :liked_items
  has_and_belongs_to_many :dislikers, class_name: "User", inverse_of: :disliked_items

end
