module Shapter
  module Entities
    class SuggestedTags < Grape::Entity
      expose :recommended_tags, using: Shapter::Entities::Tag, as: :recommended_tags
      expose :user_tags, using: Shapter::Entities::Tag, as: :user_tags
    end
  end
end

