module Shapter
  module Entities
    class Diagram < Grape::Entity
      expose :front_values
      expose :pretty_id, as: :id
     # expose :author, using: Shapter::Entities::UserShort, if: {show_author: true}
      #expose :item, using: Shapter::Entities::ItemId, unless: {show_item: true}
    end
  end
end
