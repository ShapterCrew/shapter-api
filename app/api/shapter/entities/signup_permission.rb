module Shapter
  module Entities
    class SignupPermission < Grape::Entity
      expose :email
      expose :school_names
      expose :pretty_id, as: :id
      expose :firstname
      expose :lastname
    end
  end
end


