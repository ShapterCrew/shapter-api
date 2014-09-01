module Shapter
  module Entities
    class Item < Grape::Entity

      # This test should be run first to avoid conflicts
      expose :current_user_has_diagram , if: lambda{ |u,o| o[:entity_options]["item"][:current_user_has_diagram]} do |it,ops|
        it.user_has_diagram?(ops[:entity_options][:current_user])
      end

      expose :pretty_id        , as: :id
      expose :name             , if: lambda{ |u,o| o[:entity_options]["item"][:name]}
      expose :description      , if: lambda{ |u,o| o[:entity_options]["item"][:description]}
      expose :tags             , using: Shapter::Entities::Tag  , if: lambda{ |u,o| o[:entity_options]["item"][:tags]}
      expose :comments_count   , if: lambda{ |u,o| o[:entity_options]["item"][:comments_count]}
      expose :subscribers_count, if: lambda{ |u,o| o[:entity_options]["item"][:subscribers_count]}
      expose :documents_count  , if: lambda{ |u,o| o[:entity_options]["item"][:documents_count]}

      expose :interested_users , using: Shapter::Entities::User , if: lambda{ |u,o| o[:entity_options]["item"][:interested_users]}
      expose :subscribers      , using: Shapter::Entities::User , if: lambda{ |u,o| o[:entity_options]["item"][:subscribers]}
      expose :constructor_users, as: :constructors              , using: Shapter::Entities::User, if: lambda{ |u,o| o[:entity_options]["item"][:constructors]}

      expose :current_user_subscribed , if: lambda{ |u,o| o[:entity_options]["item"][:current_user_subscribed]} do |it,ops|
        it.user_subscribed?(ops[:entity_options][:current_user])
      end

      expose :current_user_has_in_cart , if: lambda{ |u,o| o[:entity_options]["item"][:current_user_has_in_cart]} do |it,ops|
        it.user_has_in_cart?(ops[:entity_options][:current_user])
      end

      expose :current_user_has_in_constructor , if: lambda{ |u,o| o[:entity_options]["item"][:current_user_has_in_constructor]} do |it,ops|
        it.user_has_in_constructor?(ops[:entity_options][:current_user])
      end

      expose :subscribers, using: Shapter::Entities::User, if: lambda{ |u,o| o[:entity_options]["item"][:subscribers]}

      expose :current_user_comments_count , if: lambda{ |u,o| o[:entity_options]["item"][:current_user_comments_count]} do |it,ops|
        it.user_comments_count(ops[:entity_options][:current_user])
      end

      expose :current_user_diagram, using: Shapter::Entities::Diagram , if: lambda{ |u,o| o[:entity_options]["item"][:current_user_diagram]} do |it,ops|
        it.user_diagram(ops[:entity_options][:current_user])
      end

      expose :this_user_has_diagram , if: lambda{ |u,o| o[:entity_options]["item"][:this_user_has_diagram]} do |it,ops|
        it.user_has_diagram?(ops[:this_user])
      end

      expose :this_user_has_comment , if: lambda{ |u,o| o[:entity_options]["item"][:this_user_has_comment]} do |it,ops|
        it.user_has_comment?(ops[:this_user])
      end

      expose :diagrams_count, if: lambda{ |u,o| o[:entity_options]["item"][:diagrams_count]}

      expose :current_user_can_comment , if: lambda{ |u,o| o[:entity_options]["item"][:current_user_can_comment]} do |it,ops|
        it.user_can_comment?(ops[:entity_options][:current_user])
      end

      expose :comments, using: Shapter::Entities::Comment, if: lambda {|it,ops| ops[:entity_options]["item"][:comments] }

      expose :requires_comment_score, if: lambda{ |u,o| o[:entity_options]["item"][:requires_comment_score] }

      expose :shared_docs, using: Shapter::Entities::SharedDoc, if: lambda{ |u,o| o[:entity_options]["item"][:shared_docs] }

      expose :follower_friends, using: Shapter::Entities::User  , if: lambda{ |u,o| o[:entity_options]["item"][:follower_friends]} do |it,ops|
        it.subscribers & ops[:entity_options][:current_user].friends
      end

      #please leave this guy at the bottom
      expose :front_avg_diag, as: :averaged_diagram, if: lambda{ |u,o| o[:entity_options]["item"][:averaged_diagram]}


    end


  end
end
