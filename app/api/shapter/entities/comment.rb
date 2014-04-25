module Shapter
  module Entities
    class Comment < Grape::Entity
      expose :pretty_id, as: :id
      expose :content
      expose :author, using: Shapter::Entities::UserShort
      expose :work_score
      expose :quality_score
    end
  end
end

