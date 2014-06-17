module Shapter
  module Entities
    class UserId < Grape::Entity
      expose :firstname
      expose :lastname
      expose :email
      expose :pretty_id, as: :id
      expose :image
      expose :confirmed_student?, as: :confirmed_student
      expose :is_fb_friend do |user,ops|
        user.is_friend_with?(ops[:current_user])
      end
    end
  end
end


