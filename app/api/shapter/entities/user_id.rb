module Shapter
  module Entities
    class UserId < Grape::Entity
      expose :firstname
      expose :lastname
      expose :email
      expose :pretty_id, as: :id
      expose :image
    end
  end
end


