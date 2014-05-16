module Shapter
  module V3
    class Diagrams < Grape::API
      format :json

      before do 
        check_user_login!
      end

    end
  end
end
