module Shapter
  class Ping < Grape::API
    format :json

    desc "Returns pong, or passed parameter :ping if any."
    get :ping do 
      { :ping => params[:ping] || :pong}
    end

    desc "this awesome feature will increment any int variable !"
    params do 
      requires :i, type: Integer, desc: "integer to increase"
    end
    post :foo do 
      {"plus_one" => params[:i] +1}
    end
  end

end
