module Shapter
  module Entities
    class SignupPermission < Grape::Entity
      expose :email
      expose :school_name
      expose :pretty_id, as: :id
      expose :firstname
      xpose :lastname
    end
  end
end


