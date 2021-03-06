module Shapter
  module V6
    class Items < Grape::API
      helpers Shapter::Helpers::FilterHelper
      format :json

      before do 
        check_confirmed_student!
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
          present :items, f[nstart..nstop], with: Shapter::Entities::ItemShort, :current_user => current_user, show_follower_friends: true
          unless (params[:filter] - current_user.school_ids.map(&:to_s)).empty?
            Behave.delay.track current_user.pretty_id, "search on browse"
          end
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
            named_tag = Tag.find_or_create_by(name: item.name)
            item.tags << named_tag
            item.save
            named_tag.items << item 
            named_tag.save
          end
          tags.each(&:save)

          present :status, "created"
          present :items, its, with: Shapter::Entities::ItemShort, current_user: current_user

          Tag.touch
          Item.touch
        end
        #}}}

        namespace ':id' do 
          before do 
            params do 
              requires :id, type: String, desc: "id of the item to fetch"
            end
            @item = Item.find(params[:id]) || error!("item not found",404)
          end

          #{{{ get
          desc "get item infos"
          get do 
            present @item, with: Shapter::Entities::Item, :current_user => current_user
          end
          #}}}

          #{{{ subscribe
          desc "subscribe to the item"
          post :subscribe do 
            do_not_track = ( current_user.items.include?(@item))
            @item.subscribers << current_user
            if @item.save
              present @item, with: Shapter::Entities::Item, :current_user => current_user
              Behave.delay.track(current_user.pretty_id, "subscribe item", item: @item.pretty_id ) unless do_not_track
              current_user.touch unless do_not_track
              current_user.touch unless do_not_track
            else
              error!(@item.errors.messages)
            end
          end
          #}}}

          #{{{ unsubscribe
          desc "unsubscribe to the item"
          post :unsubscribe do 
            do_not_track = !(current_user.items.include?(@item))
            @item.subscribers.delete(current_user)
            if @item.save
              present @item, with: Shapter::Entities::Item, :current_user => current_user
              Behave.delay.track(current_user.pretty_id, "unsubscribe item", item: @item.pretty_id ) unless do_not_track
              current_user.touch unless do_not_track
            else
              error!(@item.errors.messages)
            end
          end
          #}}}

          #{{{ cart
          desc "add item to cart"
          post :cart do 
            do_not_track = (current_user.cart_items.include?(@item))
            @item.interested_users << current_user
            if @item.save
              present @item, with: Shapter::Entities::Item, :current_user => current_user
              Behave.delay.track(current_user.pretty_id, "add to cart", item: @item.pretty_id ) unless do_not_track
            else
              error!(@item.errors.messages)
            end
          end
          #}}}

          #{{{ uncart
          desc "removes the item from cart"
          post :uncart do 
            do_not_track = !(current_user.cart_items.include?(@item))
            @item.interested_users.delete(current_user)
            if @item.save
              present @item, with: Shapter::Entities::Item, :current_user => current_user
              Behave.delay.track(current_user.pretty_id, "remove from cart", item: @item.pretty_id ) unless do_not_track
            else
              error!(@item.errors.messages)
            end
          end
          #}}}

          #{{{ constructor
          desc "add item to constructor"
          post :constructor do 
            do_not_track = ( current_user.constructor_items.include?(@item))
            @item.constructor_users << current_user
            if @item.save
              present @item, with: Shapter::Entities::Item, :current_user => current_user
              Behave.delay.track(current_user.pretty_id, "add to constructor", item: @item.pretty_id ) unless do_not_track
            else
              error!(@item.errors.messages)
            end
          end
          #}}}

          #{{{ unconstructor
          desc "removes the item from constructor"
          post :unconstructor do 
            do_not_track = !( current_user.constructor_items.include?(@item))
            @item.constructor_users.delete(current_user)
            if @item.save
              present @item, with: Shapter::Entities::Item, :current_user => current_user
              Behave.delay.track(current_user.pretty_id, "remove from constructor", item: @item.pretty_id ) unless do_not_track
            else
              error!(@item.errors.messages)
            end
          end
          #}}}

          #{{{ destroy
          desc "destroy an item"
          delete do 
            error!("forbidden",403) unless current_user.shapter_admin

            @item.destroy

            {
              item_id: @item.id.to_s,
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
              optional :short_name, type: String, desc: "short name"
            end
          end
          put :update do 
            error!("forbidden",403) unless current_user.shapter_admin

            @item.update(params[:item])

            present @item, with: Shapter::Entities::Item, :current_user => current_user
          end
          #}}}

          #{{{ avg_diag
          desc "get the averaged diagram of the item" 
          get :avgDiag do
            present @item.front_avg_diag
          end
          #}}}

        end

      end

    end
  end
end
