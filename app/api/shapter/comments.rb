module Shapter
  class Comments < Grape::API
    format :json

    namespace :comments do 

      # {{{ destroy comment
      desc "delete your own comment"
      params do 
        requires :id, type: String, desc: "id of comment to destroy"
      end
      delete '/:id' do 
        puts "id = #{params[:id]}"
        {
          :comment_id => params[:id],
          :status => :deleted,
        }
      end
      # }}}


    end
  end
end
