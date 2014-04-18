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
          i = Item.find(params[:id])
          error!("not found",404) unless i
          i
        end
        #}}}

        #{{{ subscribe
        desc "subscribe to the item"
        put :subscribe do 
          i = Item.find(params[:id])
          error!("not found",404) unless i
          i.subscribers << current_user
          i.save
          {
            :id => i.id,
            :status => :subscribed,
          }
        end
        #}}}

        #{{{ unsubscribe
        desc "unsubscribe to the item"
        put :unsubscribe do 
          i = Item.find(params[:id])
          error!("not found",404) unless i
          i.subscribers.delete(current_user)
          i.save
          {
            :id => i.id,
            :status => :unsubscribed,
          }
        end
        #}}}

      end

    end

  end
end
