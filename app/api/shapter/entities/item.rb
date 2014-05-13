module Shapter
  module Entities
    class Item < Grape::Entity
      expose :name
      expose :description
      expose :tags, using: Shapter::Entities::Tag
      expose :pretty_id, as: :id
      expose :comments_count
      expose :subscribers_count
      expose :avg_quality_score
      expose :avg_work_score
      expose :current_user_subscribed do |it,ops|
        it.user_subscribed?(ops[:current_user])
      end
      expose :subscribers, using: Shapter::Entities::UserShort

      expose :current_user_comments_count do |it,ops|
        it.user_comments_count(ops[:current_user])
      end

      expose :comments, using: Shapter::Entities::Comment
    end
  end
end


