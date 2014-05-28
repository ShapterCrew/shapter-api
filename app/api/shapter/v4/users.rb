module Shapter
  module V4
    class Users < Grape::API
      format :json

      before do 
        check_user_login!
      end

      namespace :users do 
        namespace :me do 

          get do 
            present current_user, with: Shapter::Entities::User, :current_user => current_user
          end

          desc "comment pipe : what are the items to comment ?"
          params do 
            optional :n, type: Integer, default: 5, desc: "number of items to get"
          end
          get "comment-pipe" do 
            n = params[:n] || 5
            present :commentable_items, current_user.items.desc(:requires_comment_score).take(n), with: Shapter::Entities::ItemShort, :show_interested_users => true
          end

        end

        resource ":user_id" do 
          get do 
            user = User.find(params[:user_id]) || error!("not found",404)
            present user, with: Shapter::Entities::User, :current_user => current_user
          end

        end
      end

    end
  end
end
