module Shapter
  class Ping < Grape::API
    format :json

    desc "Returns pong."
    get :ping do 
      { :ping => params[:ping] || :pong}
    end
  end
end
