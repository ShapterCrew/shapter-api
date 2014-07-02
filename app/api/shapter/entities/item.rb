module Shapter
  module Entities
    class Item < Grape::Entity
      expose :name
      expose :description
      expose :tags, using: Shapter::Entities::Tag
      expose :pretty_id, as: :id
      expose :comments_count
      expose :subscribers_count
      expose :documents_count

      expose :interested_users, using: Shapter::Entities::User
      expose :subscribers, using: Shapter::Entities::User
      expose :constructor_users, as: :constructors, using: Shapter::Entities::User

      expose :current_user_subscribed do |it,ops|
        it.user_subscribed?(ops[:current_user])
      end

      expose :current_user_has_in_cart do |it,ops|
        it.user_has_in_cart?(ops[:current_user])
      end

      expose :current_user_has_in_constructor do |it,ops|
        it.user_has_in_constructor?(ops[:current_user])
      end

      expose :subscribers, using: Shapter::Entities::User, unless: {hide_users: true}

      expose :current_user_comments_count do |it,ops|
        it.user_comments_count(ops[:current_user])
      end

      expose :current_user_diagram, using: Shapter::Entities::Diagram do |it,ops|
        it.user_diagram(ops[:current_user])
      end

      expose :this_user_has_diagram do |it,ops|
        it.user_has_diagram?(ops[:this_user])
      end

      expose :this_user_has_comment do |it,ops|
        it.user_has_comment?(ops[:this_user])
      end

      expose :diagrams_count

      expose :user_can_view_comments, as: :allowed_to_view_comments do |it,ops|
        it.user_can_view_comments?(ops[:current_user])
      end
      expose :comments, using: Shapter::Entities::Comment, if: lambda {|it,ops| it.user_can_view_comments?(ops[:current_user]) and !ops[:hide_comments] }

      expose :requires_comment_score

      expose :shared_docs, using: Shapter::Entities::SharedDoc

      expose :follower_friends, using: Shapter::Entities::User  do |it,ops|
        it.subscribers & ops[:current_user].friends
      end

      #please leave this guy at the bottom
      expose :front_avg_diag, as: :averaged_diagram, unless: {hide_diag: true}

    end


  end
end
