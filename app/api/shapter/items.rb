module Shapter
  class Items < Grape::API
    helpers Shapter::FilterHelper
    format :json

    before do 
      check_user_login!
    end

    namespace :items do 

      #{{{ tag filter
      desc "search for an item using a list of tags"
      params do 
        requires :filter, type: Array, desc: "array of tags to filter with"
      end
      get :filter do 
        f = filter_items(params[:filter]).map(&:id)
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
