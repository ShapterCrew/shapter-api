class Item
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :tags, type: Array

  embeds_many :comments

  has_and_belongs_to_many :likers, class_name: "User", inverse_of: :liked_items
  has_and_belongs_to_many :dislikers, class_name: "User", inverse_of: :disliked_items

  has_and_belongs_to_many :tags

  has_and_belongs_to_many :subscribers, class_name: "User", inverse_of: :items

end
