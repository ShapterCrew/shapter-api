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

      expose :current_user_subscribed, if: {show_subs: true} do |it,ops|
        it.user_subscribed?(ops[:current_user])
      end

      expose :this_user_has_diagram, if: {show_user_has_diagram: true} do |it,ops|
        it.user_has_diagram?(ops[:this_user])
      end

      expose :this_user_has_comment, if: {show_user_has_comment: true} do |it,ops|
        it.user_has_comment?(ops[:this_user])
      end

      expose :current_user_diagram, using: Shapter::Entities::Diagram, if: {show_current_user_diag: true} do |it,ops|
        it.user_diagram(ops[:current_user])
      end

    end
  end
end



