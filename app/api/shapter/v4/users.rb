module Shapter
  module V4
    class Users < Grape::API
      format :json

      before do 
        check_user_login!
      end

      namespace :users do 
        get :me do 
          present current_user, with: Shapter::Entities::User, :current_user => current_user
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
