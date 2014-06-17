module Shapter
  module V5
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
          end
          get "comment-pipe" do 
            check_confirmed_student!
            n = params[:n] || 5
            r = current_user.items.not.where("comments.author_id" => current_user.id).desc(:requires_comment_score).take(n)
            present :commentable_items, r , with: Shapter::Entities::ItemShort, :show_interested_users => true
          end
          #}}}

          #{{{ friends
          desc "get my friends from facebook x shapter"
          get :friends do 
            present :friends, current_user.friends, with: Shapter::Entities::UserId, :current_user => current_user
          end
          #}}}

          #{{{ alike
          desc "get a list of users that ressemble you"
          get :alike do 
            present :alike_users, alike_users(current_user), with: Shapter::Entities::UserId, :current_user => current_user
          end
          #}}}

          #{{{ social
          desc "get a list of both users that ressemble you, and friends"
          get :social do 
            present :alike_users, alike_users(current_user), with: Shapter::Entities::UserId, :current_user => current_user
            present :friends, current_user.friends, with: Shapter::Entities::UserId, :current_user => current_user
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
