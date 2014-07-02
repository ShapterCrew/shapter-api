module Shapter
  module Entities
    class Comment < Grape::Entity
      expose :pretty_id                 , as: :id
      expose :unescaped_content         , as: :content                  , if: lambda {|it, ops| it.user_can_view_comments?(ops[:entity_options][:current_user]) and ops[:entity_options]["comment"][:content] }
      expose :author                    , using: Shapter::Entities::User, if: lambda{ |u,o| o[:entity_options]["comment"][:author] }
      expose :item                      ,                                 if: lambda{ |u,o| o[:entity_options]["comment"][:item] }
      expose :current_user_likes                                        , if: lambda{ |u,o| o[:entity_options]["comment"][:current_user_likes] } do |it,ops|
        it.user_likes?(ops[:entity_options][:current_user])
      end
      expose :likers_count              ,                                 if: lambda{ |u,o| o[:entity_options]["comment"][:likers_count] }
      expose :dislikers_count           ,                                 if: lambda{ |u,o| o[:entity_options]["comment"][:dislikers_count] }
      expose :created_at                ,                                 if: lambda{ |u,o| o[:entity_options]["comment"][:created_at] }
      expose :updated_at                ,                                 if: lambda{ |u,o| o[:entity_options]["comment"][:updated_at] }
    end
  end
end

