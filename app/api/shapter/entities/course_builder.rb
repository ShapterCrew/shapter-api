module Shapter
  module Entities
    class CourseBuilder < Grape::Entity
      expose :name
      expose :cart_items       , using: Shapter::Entities::Item, if: lambda{ |u,o| o[:entity_options]["course_builder"][:cart_items] }
      expose :subscribed_items , using: Shapter::Entities::Item, if: lambda{ |u,o| o[:entity_options]["course_builder"][:subscribed_items] }
      expose :constructor_items, using: Shapter::Entities::Item, if: lambda{ |u,o| o[:entity_options]["course_builder"][:constructor_items] }
    end
  end
end
