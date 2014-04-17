module Shapter
  class Items < Grape::API
    format :json

    namespace :items do 

      #{{{ tag filter
      desc "search for an item using a list of tags"
      params do 
        requires :filter, type: Array, desc: "array of tags to filter with"
      end
      get :filter do 
        [
          {
          :name => :foo,
          :id => 123,
          :nb_of_comments => 34,
        },
        ]
      end
      #}}}

      namespace ':id' do 
        params do 
          requires :id, type: String, desc: "id of the item to fetch"
        end

        #{{{ get
        desc "get item infos"
        get do 
          { 
            :name => :foo,
            :etc => "....etc",
          }
        end
        #}}}

        #{{{ subscribe
        desc "subscribe to the item"
        put :subscribe do 
          {
            :id => params[:id],
            :status => :subscribed,
          }
        end
        #}}}

        #{{{ unsubscribe
        desc "unsubscribe to the item"
        put :unsubscribe do 
          {
            :id => params[:id],
            :status => :unsubscribed,
          }
        end
        #}}}

      end

    end

  end
end
