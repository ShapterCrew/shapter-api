module Shapter
  module Entities
    class Tag < Grape::Entity
      expose :name
      expose :descriptio
      expose :pretty_id, as: :id
    end
  end
end
