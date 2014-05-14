module Shapter
  class ItemTagsV2 < Grape::API
    helpers Shapter::Helpers::FilterHelper
    format :json

    before do 
      check_user_login!
    end

    namespace :items do 

      namespace ':id' do 

        before do 
          params do 
            requires :id, type: String, desc: "id of the item to fetch"
          end
        end

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

            clean_name = params[:tag_name].chomp.strip

            t = Tag.find_or_create_by(name: clean_name)
            t.items << i
            t.save

            present t, with: Shapter::Entities::Tag
          end
          #}}}

          #{{{ delete
          desc "remove tag from item"
          params do 
            requires :tag_id, type: String, desc: "id of the tag to remove"
          end

          delete ':tag_id' do 
            error!("forbidden",403) unless current_user.shapter_admin
            item = Item.find(params[:id]) || error!("item not found",401)
            tag = item.tags.find(params[:tag_id]) 
            if tag
              item.remove_tag!(tag)
              {:tag => tag.name, :id => tag.pretty_id, :status => "removed from item #{item.id}"}.to_json
            else
              {:status => :ok, :msg => "item #{item.id} is not tagged with #{params[:tag_id]}"}.to_json
            end
          end

          #}}}

        end
      end

    end
  end
end
