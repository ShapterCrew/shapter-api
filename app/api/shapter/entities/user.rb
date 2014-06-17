module Shapter
  module Entities
    class User < Grape::Entity
      expose :image
      expose :pretty_id, as: :id
      expose :email
      expose :firstname
      expose :lastname
      expose :schools, using: Shapter::Entities::Tag
      expose :shapter_admin, as: :admin
      expose :confirmed?, as: :confirmed
      expose :confirmed_student?, as: :confirmed_student

      expose :items, using: Shapter::Entities::ItemShort
      expose :cart_items, using: Shapter::Entities::ItemShort
      expose :comments, using: Shapter::Entities::Comment
      expose :comments_likes_count
      expose :comments_dislikes_count
      expose :user_diagram, using: Shapter::Entities::Diagram

      expose :sign_in_count
      expose :provider
      expose :is_fb_friend do |user,ops|
        user.is_friend_with?(ops[:current_user])
      end
    end
  end
end
