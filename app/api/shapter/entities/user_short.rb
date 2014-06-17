module Shapter
  module Entities
    class UserShort < Grape::Entity
      expose :firstname
      expose :lastname
      expose :schools, using: Shapter::Entities::Tag unless {format: :no_schools}
      expose :pretty_id, as: :id
      expose :image
      expose :is_fb_friend do |user,ops|
        user.is_friend_with?(ops[:current_user])
      end
    end
  end
end

