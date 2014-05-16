module Shapter
  module Entities
    class Diagram < Grape::Entity
      expose :front_values
      expose :pretty_id, as: :id
      expose :author, using: Shapter::Entities::UserShort
      expose :item, using: Shapter::Entities::ItemId
    end
  end
end
