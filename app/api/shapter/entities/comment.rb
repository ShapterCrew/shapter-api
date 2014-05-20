module Shapter
  module Entities
    class Comment < Grape::Entity
      expose :pretty_id, as: :id
      expose :unescaped_content, as: :content
      expose :author, using: Shapter::Entities::UserId
      expose :item_id
      expose :current_user_likes do |it,ops|
        it.user_likes?(ops[:current_user])
      end
      expose :likers_count
      expose :dislikers_count
      expose :created_at
      expose :updated_at
    end
  end
end

