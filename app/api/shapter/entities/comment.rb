module Shapter
  module Entities
    class Comment < Grape::Entity
      expose :pretty_id, as: :id
      expose :content
      expose :author, using: Shapter::Entities::UserShort
      expose :work_score
      expose :quality_score
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

