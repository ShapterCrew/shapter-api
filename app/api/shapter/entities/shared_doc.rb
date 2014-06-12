module Shapter
  module Entities
    class SharedDoc < Grape::Entity
      expose :pretty_id, as: :id
      expose :name
      expose :description
      expose :file_url, as: :file
    end
  end
end
