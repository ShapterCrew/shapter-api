module Shapter
  module Entities
    class Comment < Grape::Entity
      expose :pretty_id                 , as: :id
      expose :item_id
      expose :item_name, if: lambda {|c,o| o[:entity_options]["comment"][:item_name] }
      expose :content , if: lambda {|c, ops| ops[:entity_options]["comment"][:content] } do |comm,ops|
        force = !!ops[:entity_options]["force_comments_content"] # this should be false most of the time
        comm.public_content(ops[:entity_options][:current_user],force)
      end
      expose :author                    , using: Shapter::Entities::User, if: lambda{ |u,o| o[:entity_options]["comment"][:author] }
      expose :item                      , using: Shapter::Entities::Item, if: lambda{ |u,o| o[:entity_options]["comment"][:item] }

      expose :current_user_likes , if: lambda{ |u,o| o[:entity_options]["comment"][:current_user_likes] } do |it,ops|
        it.user_likes?(ops[:entity_options][:current_user])
      end

      expose :likers_count              , if: lambda{ |u,o| o[:entity_options]["comment"][:likers_count] }
      expose :dislikers_count           , if: lambda{ |u,o| o[:entity_options]["comment"][:dislikers_count] }
      expose :created_at                , if: lambda{ |u,o| o[:entity_options]["comment"][:created_at] }
      expose :updated_at                , if: lambda{ |u,o| o[:entity_options]["comment"][:updated_at] }
    end
  end
end

