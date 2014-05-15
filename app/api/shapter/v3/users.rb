module Shapter
  module V3
    class Users < Grape::API
      format :json

      before do 
        check_user_login!
      end

      namespace :users do 
        get :me do 
          present current_user, with: Shapter::Entities::User
        end
      end

    end
  end
end
