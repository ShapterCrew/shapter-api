module Shapter
  module Entities
    class Diagram < Grape::Entity
      expose :values
      expose :author, using: Shapter::Entities::UserShort
      expose :item, using: Shapter::Entities::ItemShort, format: :id_only
    end
  end
end
