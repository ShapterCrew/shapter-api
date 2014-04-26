module Shapter
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
      end
      get :filter do 
        present filter_items(params[:filter]), with: Shapter::Entities::ItemShort, :current_user => current_user
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

        #{{{ delete
        desc "destroy an item"
        delete do 
          error!("forbidden",403) unless current_user.shapter_admin
          item = Item.find(params[:id]) || error!("not found",404)

          item.tags.each do |tag|
            tag.items.delete(item)
          end
          item.delete

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

        namespace :tags do 

          #{{{ add
          desc "tag item with tag. Only shapter_admin can do that"
          params do 
            requires :tag_name, type: String, desc: "tag name to add"
          end
          put ":tag_name" do 
            error!("denied", 401) unless current_user.shapter_admin
            i = Item.find(params[:id])
            error!("not found",404) unless i

            t = Tag.find_or_create_by(name: params[:tag_name])
            t.items << i
            t.save
            "success"
          end
          #}}}

          #{{{ delete
          desc "remove tag from item"
          params do 
            requires :tag_name, type: String, desc: "name of the tag to remove"
          end

          delete ':tag_name' do 
            error!("forbidden",403) unless current_user.shapter_admin
            item = Item.find(params[:id]) || error!("item not found",401)
            tag = item.tags.find_by(name: params[:tag_name]) 
            if tag
              item.save if item.tags.delete(tag)
              tag.reload
              tag.delete if tag.items.empty?
              {:tag => tag.name, :status => "removed from item #{item.id}"}.to_json
            else
              "item #{item.id} is not tagged with #{params[:tag_name]}"
            end
          end

          #}}}

        end

        namespace :comments do 

          #{{{ index
          desc "get comments from item"
          get do
            i = Item.find(params[:id]) || error!("not found",404)
            ok_school = (i.tags.include?(current_user.school) rescue nil)
            ok_admin = current_user.shapter_admin
            error!("access denied",401) unless (ok_admin or ok_school)

            present i.comments, with: Shapter::Entities::Comment, current_user: current_user
          end
          #}}}


        end

      end

    end

  end
end
