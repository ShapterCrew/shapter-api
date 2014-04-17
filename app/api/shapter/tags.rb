module Shapter
  class Tags < Grape::API
    format :json

    namespace :tags do 

      # index {{{
      desc "get all tags", { :notes => <<-NOTE
        Useful to build an exhaustive dictionnary of tags
        NOTE
      }
      get :/ do 
        #should return all tags
      end
      #}}}

      # suggested {{{
      desc "suggested tags to filter with", { :notes => <<-NOTE
        Given a list of set tags, and given the user's tags, this route provides an array of relevant tags, associated with their weights.
        NOTE
      }
        params do 
          requires :selected_tags, type: Array, desc: "Array of tags"
          optional :ignore_user, type: Boolean, desc: "Ignore user's tags"
        end
        post :suggested do 
          # Should return an array of [{tagname: 'foo' ,weight: bar}]
        end
      # }}}


    end

  end

end
