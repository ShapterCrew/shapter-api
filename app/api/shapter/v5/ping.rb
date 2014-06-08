require 'benchmark'
module Shapter
  module V5
    class Ping < Grape::API
      format :json

      desc "Returns pong, or passed parameter :ping if any."
      get :ping do 
        present :ping , (params[:ping] || :pong)
        present :version , 'v5'
      end

    end

  end
end
