module Shapter
  module Entities
    class ItemShort < Grape::Entity
      expose :name
      expose :pretty_id, as: :id
    end
  end
end



