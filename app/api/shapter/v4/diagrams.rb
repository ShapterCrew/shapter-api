module Shapter
  module V4
    class Diagrams < Grape::API
      format :json

      before do 
        check_confirmed_student!
      end

      namespace :items do 
        resource ':item_id' do
          before do 
            params do 
              requires :item_id, type: String, desc: "id of the item to fetch"
            end
          end

          namespace :mydiagram do 

            #{{{ create_or_update - post
            desc "create or update my diagram", {
              :notes => <<-NOTE
              expected arguments format to set the values: 

                  :values => {
                  0 => 3, # x_0 is assigned to 3
                  3 => 1, # x_1 is assigned to 1
                  }

              NOTE
            }
            params do
              requires :values, type: Hash 
            end
            put do
              i = Item.find(params[:item_id]) || error!("item not found",500)
              d = i.diagrams.find_or_create_by(author: current_user)
              params[:values].each do |i,v|
                d.values ||= Array.new(Diagram.values_size)
                d.values[i.to_i] = v.to_i
              end
              if d.save
                present d, with: Shapter::Entities::Diagram, current_user: current_user

                Behave.delay.track current_user.pretty_id, "edit a diagram", item: i.pretty_id 
              else
                error!(d.errors.messages)
              end
            end
            #}}}

            #{{{ delete
            desc "delete my diagram"
            delete do
              i = Item.find(params[:item_id]) || error!("item not found",500)
              d = i.diagrams.find_by(author: current_user)
              if d
                d.destroy
                i.save
                {:status => :destroyed}
              else
                error!("not found",404)
              end

            end
            #}}}

            #{{{ get
            desc "get my diagram"
            get do
              i = Item.find(params[:item_id]) || error!("item not found",500)
              d = i.diagrams.find_by(author: current_user)
              present d, with: Shapter::Entities::Diagram, current_user: current_user
            end
            #}}}

          end
        end

      end
    end
  end
end
