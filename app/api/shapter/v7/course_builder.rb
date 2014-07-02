require 'ostruct'
module Shapter
  module V7
    class CourseBuilder < Grape::API
      format :json

      before do 
        check_confirmed_student!
      end

      namespace :users do
        namespace ":user_id" do 
          before do 
            params do 
              requires :user_id, type: String, desc: "id of the user"
            end
            @user = User.find(params[:user_id])
          end

          namespace :courses do 

            #{{{ courses 
            desc "for each constructor_funnel step, get the list of items that intersect constructor_funnel & current_user cart/items/constructor_items"
            params do 
              requires :schoolTagId, type: String, desc: "id of the tag that represent the user's school"
              optional :displayCart, type: Boolean, desc: "choose wether the cart items should be displayed", default: false
              optional :displayConstructor, type: Boolean, desc: "choose wether the constructor items should be displayed", default: false
            end
            get do 
              school = Tag.find(params[:schoolTagId]) || error!("tag not found",404)
              error!("forbidden" ,401) unless @user.schools.include? school

              error!("school #{school.name} has no constructor funnel") if school.constructor_funnel.blank?

              cart = @user.cart_item_ids
              builder = school.constructor_funnel.map do |h|
                OpenStruct.new({
                  name: h["name"],
                  subscribed_items: @user.items.all_in(tag_ids: h["tag_ids"]),
                }
                .merge( !!params[:displayCart] ? {cart_items: @user.cart_items.all_in(tag_ids: h["tag_ids"])} : {} )
                .merge( !!params[:displayConstructor] ? {constructor_items: @user.constructor_items.all_in(tag_ids: h["tag_ids"])} : {})
                      )

              end

              present builder,
                with: Shapter::Entities::CourseBuilder,
                entity_options: entity_options,
                this_user: @user

            end
            #}}}

          end
        end
      end
    end

  end
end
