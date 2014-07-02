module Shapter
  module Entities
    class User < Grape::Entity
      expose :pretty_id                       , as: :id
      expose :image                           , if: lambda {|u,o| o[:entity_options]["user"][:image] }
      expose :firstname                       , if: lambda {|u,o| o[:entity_options]["user"][:firstname]}
      expose :lastname                        , if: lambda {|u,o| o[:entity_options]["user"][:lastname]}
      expose :schools                         , using: Shapter::Entities::Tag    , if: lambda { |u,o| o[:entity_options]["user"][:schools]}
      expose :shapter_admin                   , as: :admin                       , if: lambda { |u,o| o[:entity_options]["user"][:admin]}
      expose :confirmed?                      , as: :confirmed                   , if: lambda { |u,o| o[:entity_options]["user"][:confirmed]}
      expose :confirmed_student?              , as: :confirmed_student           , if: lambda { |u,o| o[:entity_options]["user"][:confirmed_student]}

      expose :comments                        , using: Shapter::Entities::Comment, if: lambda { |u,o| o[:entity_options]["user"][:comments]}
      expose :comments_likes_count            , if: lambda { |u,o| o[:entity_options]["user"][:comments_likes_count]}
      expose :comments_dislikes_count         , if: lambda { |u,o| o[:entity_options]["user"][:comments_dislikes_count]}
      expose :user_diagram                    , using: Shapter::Entities::Diagram, if: lambda { |u,o| o[:entity_options]["user"][:user_diagram]}

      expose :sign_in_count                   , if: lambda { |u,o| o[:entity_options]["user"][:sign_in_count]}
      expose :provider                        , if: lambda { |u,o| o[:entity_options]["user"][:provider]}
      expose :is_fb_friend                    , if: lambda { |u,o| o[:entity_options]["user"][:is_fb_friend]} do |user,ops|
        user.is_friend_with?(ops[:entity_options][:current_user])
      end

      expose :comments_count                  , if: lambda { |u,o| o[:entity_options]["user"][:comments_count]}
      expose :items_count                     , if: lambda { |u,o| o[:entity_options]["user"][:items_count]}
      expose :diagrams_count                  , if: lambda { |u,o| o[:entity_options]["user"][:diagrams_count]}
    end
  end
end
