module Shapter
  module V6
    class Users < Grape::API
      helpers Shapter::Helpers::UsersHelper
      format :json

      before do 
        #check_confirmed_student!
        check_user_login!
      end

      namespace :users do 

        namespace :me do 

          #{{{ /users/me
          get do 
            present current_user, with: Shapter::Entities::User, :current_user => current_user
          end
          #}}}

          #{{{ comment pipe
          desc "comment pipe : what are the items to comment ?"
          params do 
            optional :n, type: Integer, default: 5, desc: "number of items to get"
            optional :n_start, type: Integer, default: 0, desc: "starting index. default = 0 to get the first item"
          end
          get "comment-pipe" do 
            check_confirmed_student!
            n        = params[:n]       || 5
            n_start  = params[:n_start] || 0

            r = current_user.items.not.where("comments.author_id" => current_user.id).desc(:requires_comment_score).skip(n_start).take(n)
            present :commentable_items, r , with: Shapter::Entities::ItemShort,
              current_user: current_user,
              :show_current_user_diag => true
          end
          #}}}

          #{{{ friends
          desc "get my friends from facebook x shapter"
          get :friends do 
            check_confirmed_student!
            present :friends, current_user.friends, with: Shapter::Entities::UserId, :current_user => current_user
          end
          #}}}

          #{{{ alike
          desc "get a list of users that ressemble you"
          get :alike do 
            check_confirmed_student!
            present :alike_users, alike_users(current_user), with: Shapter::Entities::UserId, :current_user => current_user
          end
          #}}}

          #{{{ social
          desc "get a list of both users that ressemble you, and friends"
          get :social do 
            check_confirmed_student!
            present :alike_users, alike_users(current_user), with: Shapter::Entities::UserId, :current_user => current_user
            present :friends, current_user.friends, with: Shapter::Entities::UserId, :current_user => current_user
          end
          #}}}

          #{{{ leaderboard
          desc  "get a leaderboard from behave.io, that intersects the user's schools"
          params do 
            optional :max, type: Integer, default: 10, desc: "max number of elements. default 10"
          end
          get :leaderboard do 
            check_confirmed_student!
            a = Behave::Leaderboard.results("points").reject do |h|
              s1 =  (h[:player][:traits][:schools] rescue [] ) || []
              s2 = current_user.schools.map(&:name)
              (s1 & s2).empty?
            end
            present :leaderboard, a.take(params[:max] || 10)
          end
          #}}}

          #{{{ latest_comments
          desc "returns a list of latest comments in my subscribed items, my cart items, my constructor items"
          params do 
            optional :hide_my_items         , type: Boolean, desc: "do not present user's items comments"           , default: false
            optional :hide_cart_items       , type: Boolean, desc: "do not present cart items comments"             , default: false
            optional :hide_constructor_items, type: Boolean, desc: "do not present constructor items comments"      , default: false

            optional :my_max                , type: Integer, desc: "maximum items in my list. default = 10"         , default: 10
            optional :cart_max              , type: Integer, desc: "maximum items in cart list. default = 10"       , default: 10
            optional :constructor_max       , type: Integer, desc: "maximum items in constructor list. default = 10", default: 10
          end
          get :latest_comments do

            unless params[:hide_my_items]
              my_items             = current_user.items            .not.where(comments: nil).flat_map(&:comments).sort_by{|c| c.updated_at}.reverse.take(params[:my_max])
              present(:my_item_comments         , my_items, with: Shapter::Entities::Comment, current_user: current_user) 
            end
            unless params[:hide_cart_items]
              my_cart_items        = current_user.cart_items       .not.where(comments: nil).flat_map(&:comments).sort_by{|c| c.updated_at}.reverse.take(params[:cart_max])
              present(:cart_item_comments       , my_cart_items, with: Shapter::Entities::Comment, current_user: current_user) 
            end
            unless params[:constructor_items]
              my_constructor_items = current_user.constructor_items.not.where(comments: nil).flat_map(&:comments).sort_by{|c| c.updated_at}.reverse.take(params[:constructor_max])
              present(:constructor_item_comments, my_constructor_items, with: Shapter::Entities::Comment, current_user: current_user) 
            end
          end
          #}}}

        end

        resource ":user_id" do 
          before do 
            params do 
              requires :user_id, type: String, desc: "id of the user"
            end
            @user = User.find(params[:user_id]) || error!("not found",404)
          end

          #{{{ alike
          desc "get a list of users that ressemble the user"
          get :alike do 
            check_confirmed_student!
            present :alike_users, alike_users(@user), with: Shapter::Entities::UserId, :current_user => current_user
          end
          #}}}

          #{{{ get user
          get do 
            check_confirmed_student!
            present @user, with: Shapter::Entities::User, :current_user => current_user
          end
          #}}}

          #{{{ friends
          desc "get user's friends from facebook x shapter"
          get :friends do 
            present @user.friends, with: Shapter::Entities::UserId, :current_user => current_user
          end
          #}}}

        end
      end

    end
  end
end
