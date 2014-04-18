class Comment
  include Mongoid::Document
  field :content, type: String

  embedded_in :item
  belongs_to :author, class_name: "User"

end
