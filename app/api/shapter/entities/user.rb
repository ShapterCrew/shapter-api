module Shapter
  module Entities
    class User < Grape::Entity
      expose :email
      expose :firstname
      expose :lastname
      expose :school, using: Shapter::Entities::Tag
      expose :shapter_admin, as: :admin
    end
  end
end
