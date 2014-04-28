module Shapter
  module Entities
    class UserShort < Grape::Entity
      expose :firstname
      expose :lastname
      expose :schools, using: Shapter::Entities::Tag
      expose :pretty_id, as: :id
    end
  end
end

