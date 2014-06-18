module Shapter
  module Entities
    class CourseBuilder < Grape::Entity

      expose :name
      expose :cart_items, using: Shapter::Entities::ItemShort
      expose :subscribed_items, using: Shapter::Entities::ItemShort
      expose :constructor_items, using: Shapter::Entities::ItemShort

    end
  end
end
