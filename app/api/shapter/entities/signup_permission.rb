module Shapter
  module Entities
    class SignupPermission < Grape::Entity
      expose :pretty_id, as: :id
      expose :email       , if: lambda{ |u,o| o[:entity_options]["signup_permission"][:email]}
      expose :school_names, if: lambda{ |u,o| o[:entity_options]["signup_permission"][:school_names]}
      expose :firstname   , if: lambda{ |u,o| o[:entity_options]["signup_permission"][:firstname]}
      expose :lastname    , if: lambda{ |u,o| o[:entity_options]["signup_permission"][:lastname]}
    end
  end
end


