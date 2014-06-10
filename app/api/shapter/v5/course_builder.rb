require 'ostruct'
module Shapter
  module V5
    class CourseBuilder < Grape::API
      format :json

      before do 
        check_confirmed_student!
      end

      namespace :users do
        namespace :me do 
          namespace :courses do 
            namespace :builder do 

              #{{{ courses builder
              desc "for each signup_funnel step, get the list of items that intersect signup_funnel & current_user cart"
              params do 
                requires :schoolTagId, type: String, desc: "id of the tag that represent the user's school"
              end
              get do 
                school = Tag.find(params[:schoolTagId]) || error!("tag not found",404)
                error!("forbidden" ,401) unless current_user.schools.include? school

                error!("school #{school.name} has no signup funnel") if school.signup_funnel.blank?

                cart = current_user.cart_item_ids
                builder = school.signup_funnel.map do |h|
                  OpenStruct.new({
                    name: h["name"],
                    cart_items: current_user.cart_items.all_in(tag_ids: h["tag_ids"]),
                    subscribed_items: current_user.items.all_in(tag_ids: h["tag_ids"]),
                  })

                end

                present builder, with: Shapter::Entities::CourseBuilder, current_user: current_user, hide_comments: true, hide_users: true, hide_diag: true

              end
              #}}}

            end
          end
        end
      end

    end
  end
end
