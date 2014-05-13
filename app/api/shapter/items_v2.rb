module Shapter
  class ItemsV2 < Grape::API
    helpers Shapter::Helpers::FilterHelper
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
        present filter_items2(params[:filter]), with: Shapter::Entities::ItemShort, :current_user => current_user
      end
      #}}}

      #{{{ suggested
      desc "suggestion of items the current user might want to subscribe to."
      params do 
        optional :limit, type: Integer, desc: "limit of questions to ask. default 5", default: 5
        optional :exl, type: Array, desc: "list of item ids to exclude from reco"
      end
      get :suggested do 
        exclude = params[:exl] || []
        present reco_item(current_user,params[:limit],exclude), with: Shapter::Entities::ItemShort
      end
      #}}}

      namespace ':id' do 
        before do 
          params do 
            requires :id, type: String, desc: "id of the item to fetch"
          end
        end

        #{{{ get
        desc "get item infos"
        get do 
          i = Item.find(params[:id])
          error!("not found",404) unless i
          present i, with: Shapter::Entities::Item, :current_user => current_user
        end
        #}}}

        #{{{ subscribe
        desc "subscribe to the item"
        post :subscribe do 
          i = Item.find(params[:id])
          error!("not found",404) unless i
          i.subscribers << current_user
          i.save
          i.reload
          present i, with: Shapter::Entities::Item, :current_user => current_user
        end
        #}}}

        #{{{ unsubscribe
        desc "unsubscribe to the item"
        post :unsubscribe do 
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

        #{{{ destroy
        desc "destroy an item"
        delete do 
          error!("forbidden",403) unless current_user.shapter_admin
          item = Item.find(params[:id]) || error!("not found",404)

          item.destroy

          {
            item_id: item.id.to_s,
            status: :destroyed
          }.to_json

        end
        #}}}

        #{{{ update
        desc "update an item" 
        params do 
          requires :item, type: Hash do 
            optional :name, type: String, desc: "item name"
            optional :description, type: String, desc: "description"
          end
        end
        put :update do 
          error!("forbidden",403) unless current_user.shapter_admin
          item = Item.find(params[:id]) || error!("not found",404)

          item.update(params[:item])

          present item, with: Shapter::Entities::Item, :current_user => current_user
        end
        #}}}

      end

    end

  end
end
