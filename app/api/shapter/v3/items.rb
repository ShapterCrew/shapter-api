module Shapter
  module V3
    class Items < Grape::API
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
          optional :n_start, type: Integer, desc: "index to start with. default: 0", default: 0
          optional :n_stop, type: Integer, desc: "index to end with. default: 14. -1 will return the entire list", default: 14
        end
        get :filter do 
          nstart = params[:n_start].to_i
          nstop = params[:n_stop].to_i
          f = filter_items2(params[:filter])
          present :number_of_results, f.size
          present :items, f[nstart..nstop], with: Shapter::Entities::ItemShort, :current_user => current_user
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

        #{{{ create
        desc "create multiple items, all of them being tagged with some tags (using tag names)"
        params do 
          requires :itemNames, type: Array, desc: "name of the items to create"
          optional :tagNames, type: Array, desc: "array of tag names to associate with the created items" 
        end
        post :create_with_tags do 
          check_user_admin!
          its  = params[:itemNames].map{|n| Item.new(name: n.strip)}
          tags = params[:tagNames].map{|n| Tag.find_or_create_by(name: n.strip)}

          its.each do |item|
            tags.each{|t| item.tags << t}
            item.tags << Tag.find_or_create_by(name: item.name)
            item.save
          end
          tags.each(&:save)

          present :status, "created"
          present :items, its, with: Shapter::Entities::ItemShort
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

          #{{{ cart
          desc "add item to cart"
          post :cart do 
            i = Item.find(params[:id])
            error!("not found",404) unless i
            i.interested_users << current_user
            i.save
            i.reload
            present i, with: Shapter::Entities::Item, :current_user => current_user
          end
          #}}}

          #{{{ uncart
          desc "removes the item from cart"
          post :uncart do 
            i = Item.find(params[:id])
            error!("not found",404) unless i
            i.interested_users.delete(current_user)
            i.save
            i.reload
            present i, with: Shapter::Entities::Item, :current_user => current_user
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
end
