require 'benchmark'
module Shapter
  module V7
    class Ping < Grape::API
      format :json


      desc "Returns pong, or passed parameter :ping if any."
      get :ping do 
        #present :ping , (params[:ping] || :pong)
        #present :version , 'v7'
        present (Tag.find_by(name: "Eurecom")).best_comment
      end

    end

  end
end
