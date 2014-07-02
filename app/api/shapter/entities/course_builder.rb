module Shapter
  module Entities
    class CourseBuilder < Grape::Entity

      expose :name
      expose :cart_items, using: Shapter::Entities::Item
      expose :subscribed_items, using: Shapter::Entities::Item
      expose :constructor_items, using: Shapter::Entities::Item

    end
  end
end
