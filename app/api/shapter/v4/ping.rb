require 'benchmark'
module Shapter
  module V4
    class Ping < Grape::API
      format :json

      desc "Returns pong, or passed parameter :ping if any."
      get :ping do 
        present :ping , (params[:ping] || :pong)
        present :version , 'v3'
      end

    end

  end
end
