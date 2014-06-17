module Shapter
  module Entities
    class SharedDoc < Grape::Entity
      expose :pretty_id, as: :id
      expose :name
      expose :description
      expose :file_url, as: :file
      expose :dl_count, as: :dlCount
      expose :author, using: Shapter::Entities::UserId
    end
  end
end
