module Shapter
  module Entities
    class Category < Grape::Entity
      expose :pretty_id, as: :id
      expose :code, if: lambda{|c,o| o[:entity_options]["category"][:code] }
    end
  end
end
