require 'ostruct'
module Shapter
  module V3
    class Tags < Grape::API
      format :json

      helpers Shapter::Helpers::FilterHelper

      before do 
        check_user_login!
      end

      namespace :tags do 

        # index {{{
        desc "get all tags", { :notes => <<-NOTE
        Useful to build an exhaustive dictionnary of tags

        A <filter> parameter can be passed to build a dictionnary based on some school.
        If specified, then all the tags will have at least one item that is tagged by the school.
          NOTE
        }
        params do 
        end
        get :/ do 
          if params[:filter]
            present dictionnary(params[:filter]), with: Shapter::Entities::Tag
          else
            present Tag.all, with: Shapter::Entities::Tag
          end
        end
        #}}}

        # suggested {{{
        desc "suggested tags to filter with", { :notes => <<-NOTE
        Given a list of set tags, and given the user's tags, this route provides an array of relevant tags, associated with their weights.
          NOTE
        }
        params do 
          requires :selected_tags, type: Array, desc: "Array of tags"
          optional :ignore_user, type: Boolean, desc: "Ignore user's tags"
          optional :limit, type: Integer, desc: "Limit the max number of results", default: 20
        end

        post :suggested do 

          ignore_user = params[:ignore_user]

          resp = { :recommended_tags => reco_tags2(params[:selected_tags],params[:limit]) }
          .merge( ignore_user ? {} : { :user_tags => current_user.items.flat_map(&:tags).uniq })

          present OpenStruct.new(resp), with: Shapter::Entities::SuggestedTags 

        end
        # }}}

        #{{{ batch_tag
        desc "add a tag to multiple items at the same time"
        params do 
          requires :item_ids_list, type: Array, desc: "list of item ids to tag"
          requires :tag_name, type: String, desc: "The name of the tag"
        end
        post :batch_tag do 

          error!("forbidden",403) unless current_user.shapter_admin

          tag = Tag.find_or_create_by(name: params[:tag_name].chomp.strip)
          Item.any_in(id: params[:item_ids_list]).each do |item|
            tag.items << item
          end
          if tag.save
            tag.reload
            present tag, with: Shapter::Entities::TagFull
          else
            error!
          end

        end
        #}}}

        namespace ":tag_id" do 
          before do 
            params do 
              requires :tag_id, type: String, desc: "The tag id"
            end
          end

          #{{{ udpate
          desc "update tag's attributes"
          params do 
            optional :name, type: String, desc: "tag name"
            optional :description, type: String, desc: "tag description"
            optional :type, type: String, desc: "tag type"
          end
          put do 
            error!("forbidden",403) unless current_user.shapter_admin

            tag_params = [:name,:description,:type].reduce({}) do |h,p|
              h.merge( params[p] ? {p => params[p]} : {} )
            end

            Tag.find(params[:tag_id]).update(tag_params)
          end
          #}}}end

          #{{{ show
          desc "show tag"
          get "" do 
            t = Tag.find(params[:tag_id])
            present t, with: Shapter::Entities::TagFull
          end
          #}}}

          #{{{ destroy
          desc "delete tag"
          delete "" do 
            error!("forbidden",403) unless current_user.shapter_admin
            t = Tag.find(params[:tag_id])
            t.destroy
            {:id => t.id.to_s, :status => :destroyed}.to_json
          end
        end
        #}}}

      end
    end

  end
end
