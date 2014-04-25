module Shapter
  module Entities
    class TagFull < Grape::Entity
      expose :name
      expose :pretty_id, as: :id
      expose :items, using: Shapter::Entities::ItemShort
    end
  end
end

