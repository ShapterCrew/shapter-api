module Shapter
  module Entities
    class UserId < Grape::Entity
      expose :firstname
      expose :lastname
      expose :email
      expose :pretty_id, as: :id
      expose :image
      expose :confirmed_student?, as: :confirmed_student
    end
  end
end


