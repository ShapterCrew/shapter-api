module Shapter
  module Entities
    class Tag < Grape::Entity
      expose :pretty_id, as: :id
      expose :name
      expose :short_name
      expose :items, using: Shapter::Entities::Item
      expose :type
    end
  end
end
