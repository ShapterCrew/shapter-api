module Shapter
  module Entities
    class User < Grape::Entity
      expose :email
      expose :firstname
      expose :lastname
    end
  end
end
