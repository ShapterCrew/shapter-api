module Shapter
  module Entities
    class Diagram < Grape::Entity
      expose :front_values
      expose :pretty_id, as: :id
      expose :author, using: Shapter::Entities::User
      expose :item, using: Shapter::Entities::Item
    end
  end
end
