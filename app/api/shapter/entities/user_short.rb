module Shapter
  module Entities
    class UserShort < Grape::Entity
      expose :firstname
      expose :lastname
      expose :schools, using: Shapter::Entities::Tag unless {format: :no_schools}
      expose :pretty_id, as: :id
      expose :image
    end
  end
end

