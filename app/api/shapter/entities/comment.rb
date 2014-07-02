module Shapter
  module Entities
    class Comment < Grape::Entity
      expose :pretty_id, as: :id
      expose :unescaped_content, as: :content, if: lambda {|it,ops| it.user_can_view_comments?(ops[:current_user]) }
      expose :author, using: Shapter::Entities::User
      expose :item_id
      expose :current_user_likes do |it,ops|
        it.user_likes?(ops[:current_user])
      end
      expose :likers_count
      expose :dislikers_count
      expose :created_at
      expose :updated_at
      expose :item_name, as: :course_name
    end
  end
end

