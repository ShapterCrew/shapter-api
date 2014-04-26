module Shapter
  module Entities
    class ItemShort < Grape::Entity
      expose :name
      expose :pretty_id, as: :id
      expose :comments_count
    end
  end
end



