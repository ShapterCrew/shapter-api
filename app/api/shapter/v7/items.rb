module Shapter
  module V7
    class Items < Grape::API
      helpers Shapter::Helpers::FilterHelper
      format :json

      before do 
        #check_confirmed_student!
        check_confirmed_account!
      end

      namespace :items do 

        #{{{ recommended
        desc "the courses you'll like !"
        params do 
          optional :max_number, type: Integer, desc: "max number of suggested items", default: 10
        end
        post :recommended do 
          max = params[:max_number] || 10
          present items_reco(current_user,max), with: Shapter::Entities::Item, entity_options: entity_options
        end
        #}}}

        #{{{ cart recommended
        desc "the courses you'll like ! (cart version: it suggest items based on your cart)"
        params do 
          optional :max_number,type: Integer,  desc: "max number of suggested items", default: 10
        end
        post :recommended do 
          max = params[:max_number] || 10
          present cart_items_reco(current_user,max), with: Shapter::Entities::Item, entity_options: entity_options
        end
        #}}}

        #{{{ tag filter
        desc "search for an item using a list of tags"
        params do 
          requires :filter, type: Array, desc: "array of tags to filter with"
          optional :n_start, type: Integer, desc: "index to start with. default: 0", default: 0
          optional :n_stop, type: Integer, desc: "index to end with. default: 14. -1 will return the entire list", default: 14

          optional :quality_filter, type: Boolean, desc: "passing any value will result in a filtering by quality of avg_diags instead of name"
          optional :cart_only, type: Boolean, desc: "look only for items that are in my favorites"
        end
        post :filter do 
          nstart = params[:n_start].to_i
          nstop = params[:n_stop].to_i

          f = if !!params[:quality_filter]
                quality_filter(params[:filter])
              else
                filter_items2(params[:filter])
              end

          results = if !!params[:cart_only]
                      (f & current_user.cart_items)
                    else
                      f
                    end

          present :number_of_results, results.size
          present :items, results[nstart..nstop], with: Shapter::Entities::Item, entity_options: entity_options
          unless (params[:filter] - current_user.school_ids.map(&:to_s)).empty?
            Behave.delay.track current_user.pretty_id, "search on browse"
          end
        end
        #}}}

        #{{{ create with tags
        desc "create multiple items, all of them being tagged with some tags (using tag names)"
        params do 
          requires :item_names, type: Array, desc: "name of the items to create"
          requires :tags, type: Array do 
            requires :tag_name, type: String, desc: "name of the tag"
            requires :category_id, type: String, desc: "category if of the tag"
          end
        end
        post :create_with_tags do 
          check_user_admin!

          tags = params[:tags].map do |tag|
            cat = Category.find(tag["category_id"]) || error!("category not found")
            Tag.find_or_create_by(name: tag["tag_name"], category_id: cat.id)
          end

          items = params[:item_names].map do |item_name|
            Item.create(name: item_name)
          end

          cat = Category.find_or_create_by(code: "item_name")

          items.each do |item|
            special_tag = Tag.find_or_create_by(name: item.name, category_id: cat.id)
            (tags + [special_tag]).each do |tag|
              item.add_to_set(tag_ids: tag.id)
              tag.add_to_set(item_ids: item.id)
            end
          end

          items.each(&:touch)
          tags.each(&:touch)

          present :status, :created
          present :tags, tags, with: Shapter::Entities::Tag, entity_options: entity_options
          present :items, items, with: Shapter::Entities::Item, entity_options: entity_options

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
          post do 
            present @item, with: Shapter::Entities::Item, entity_options: entity_options
          end
          #}}}

          #{{{ subscribe
          desc "subscribe to the item"
          post :subscribe do 
            check_confirmed_student!
            error!("user is no verified student of this school",401) unless @item.user_can_comment?(current_user)
            do_not_track = ( current_user.items.include?(@item))
            @item.subscribers << current_user
            if @item.save
              present @item, with: Shapter::Entities::Item, entity_options: entity_options
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
            check_confirmed_student!
            error!("user is no verified student of this school",401) unless @item.user_can_comment?(current_user)
            do_not_track = !(current_user.items.include?(@item))
            @item.subscribers.delete(current_user)
            if @item.save
              present @item, with: Shapter::Entities::Item, entity_options: entity_options
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
            error!("user is no verified student of this school",401) unless @item.user_can_comment?(current_user)
            do_not_track = (current_user.cart_items.include?(@item))
            @item.interested_users << current_user
            if @item.save
              present @item, with: Shapter::Entities::Item, entity_options: entity_options
              Behave.delay.track(current_user.pretty_id, "add to cart", item: @item.pretty_id ) unless do_not_track
            else
              error!(@item.errors.messages)
            end
          end
          #}}}

          #{{{ uncart
          desc "removes the item from cart"
          post :uncart do 
            error!("user is no verified student of this school",401) unless @item.user_can_comment?(current_user)
            do_not_track = !(current_user.cart_items.include?(@item))
            @item.interested_users.delete(current_user)
            if @item.save
              present @item, with: Shapter::Entities::Item, entity_options: entity_options
              Behave.delay.track(current_user.pretty_id, "remove from cart", item: @item.pretty_id ) unless do_not_track
            else
              error!(@item.errors.messages)
            end
          end
          #}}}

          #{{{ constructor
          desc "add item to constructor"
          post :constructor do 
            error!("user is no verified student of this school",401) unless @item.user_can_comment?(current_user)
            do_not_track = ( current_user.constructor_items.include?(@item))
            @item.constructor_users << current_user
            if @item.save
              present @item, with: Shapter::Entities::Item, entity_options: entity_options
              Behave.delay.track(current_user.pretty_id, "add to constructor", item: @item.pretty_id ) unless do_not_track
            else
              error!(@item.errors.messages)
            end
          end
          #}}}

          #{{{ unconstructor
          desc "removes the item from constructor"
          post :unconstructor do 
            error!("user is no verified student of this school",401) unless @item.user_can_comment?(current_user)
            do_not_track = !( current_user.constructor_items.include?(@item))
            @item.constructor_users.delete(current_user)
            if @item.save
              present @item, with: Shapter::Entities::Item, entity_options: entity_options
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

            ok_params = [
              !!(x = params[:item][:name])        ? {name: x}        : {},
              !!(x = params[:item][:description]) ? {description: x} : {},
              !!(x = params[:item][:short_name])  ? {short_name: x}  : {},
            ].reduce(&:merge)

            @item.update_attributes(ok_params)

            present @item, with: Shapter::Entities::Item, entity_options: entity_options
          end
          #}}}

          #{{{ avg_diag
          desc "get the averaged diagram of the item" 
          post :avgDiag do
            present @item.front_avg_diag
          end
          #}}}

        end

      end

    end
  end
end
