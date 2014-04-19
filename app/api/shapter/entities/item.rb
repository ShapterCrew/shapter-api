module Shapter
  module Entities
    class Item < Grape::Entity
      expose :name
      expose :description
      expose :tags, using: Shapter::Entities::Tag
      expose :id, :id
      expose :comments_count
      expose :current_user_likes do |it,ops|
        it.user_likes?(ops[:current_user])
      end
    end
  end
end


