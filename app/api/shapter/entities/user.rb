module Shapter
  module Entities
    class User < Grape::Entity
      expose :pretty_id, as: :id
      expose :email
      expose :firstname
      expose :lastname
      expose :schools, using: Shapter::Entities::Tag
      expose :shapter_admin, as: :admin
      expose :confirmed?, as: :confirmed
    end
  end
end
