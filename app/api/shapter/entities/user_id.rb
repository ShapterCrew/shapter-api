module Shapter
  module Entities
    class UserId < Grape::Entity
      expose :firstname
      expose :lastname
      expose :pretty_id, as: :id
      expose :image, unless: {no_image: true}
      expose :confirmed_student?, as: :confirmed_student, unless: {no_confirm: true}
      expose :is_fb_friend, unless: {no_fb_friends: true} do |user,ops|
        user.is_friend_with?(ops[:current_user])
      end
    end
  end
end


