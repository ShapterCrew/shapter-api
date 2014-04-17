module Shapter
  class Ping < Grape::API
    format :json

    desc "Returns pong, or passed parameter :ping if any."
    get :ping do 
      { :ping => params[:ping] || pong}
    end

  end

end
