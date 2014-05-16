module Shapter
  module Entities
    class ItemId < Grape::Entity
      expose :name
      expose :pretty_id, as: :id
    end
  end
end



