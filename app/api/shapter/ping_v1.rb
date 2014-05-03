module Shapter
  class PingV1 < Grape::API
    format :json

    desc "Returns pong, or passed parameter :ping if any."
    get :ping do 
      { :ping => (params[:ping] || :pong), :version => 'v1'}
    end

  end

end
