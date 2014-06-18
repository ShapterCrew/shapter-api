module Shapter
  module Entities
    class ItemShort < Grape::Entity
      expose :diagrams_count
      expose :name
      expose :pretty_id, as: :id
      expose :comments_count    
      expose :subscribers_count 
      expose :front_avg_diag, as: :averaged_diagram 
      expose :requires_comment_score
      expose :interested_users, using: Shapter::Entities::UserId, if: {show_users: true}
      expose :subscribers, using: Shapter::Entities::UserId, if: {show_users: true}
      expose :constructor_users, as: :constructors, using: Shapter::Entities::UserId, if: {show_users: true}
    end
  end
end



