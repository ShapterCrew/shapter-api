module Shapter
  class PingV2 < Grape::API
    format :json

    desc "Returns pong, or passed parameter :ping if any."
    get :ping do 
      { :ping => (params[:ping] || :pong), :version => 'v2'}
    end

  end

end
