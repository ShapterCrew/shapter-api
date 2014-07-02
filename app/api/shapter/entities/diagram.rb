module Shapter
  module Entities
    class Diagram < Grape::Entity
      expose :pretty_id   , as: :id
      expose :front_values, if: lambda{ |u,o| o[:entity_options]["diagram"][:front_values] }
      expose :author      , using: Shapter::Entities::User , if: lambda { |u,o| o[:entity_options]["diagram"][:author]}
      expose :item        , using: Shapter::Entities::Item , if: lambda { |u,o| o[:entity_options]["diagram"][:item]}
    end
  end
end
