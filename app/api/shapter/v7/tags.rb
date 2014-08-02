require 'ostruct'
module Shapter
  module V7
    class Tags < Grape::API
      format :json

      helpers Shapter::Helpers::FilterHelper

      before do 
        #check_confirmed_student!
        check_user_login!
      end

      namespace :tags do 

        #{{{ elasticsearch
        desc "search for tag name"
        params do 
          requires :search, type: String, desc: 'required: search string'
          optional :category_id, type: String, desc: 'optional: category_id to filter with'
          optional :category_code, type: String, desc: 'optional: category_code to filter with'
        end
        post :elasticsearch do 
          
          tags = Tag.es.search({body: { query: {match: {name: params[:search]}} }}).select{ |tag|
            if params[:category_id]
              tag.category_id == (@cat ||= BSON::ObjectId.from_string(params[:category_id]))
            elsif params[:category_code]
              tag.category_id == (@cat ||= Category.find_by(code: params[:category_code]).id)
            else
              true
            end
          }
          present :tags, tags, with: Shapter::Entities::Tag, entity_options: entity_options
        end
        #}}}

        # index {{{
        desc "get all tags", { :notes => <<-NOTE
        Useful to build an exhaustive dictionnary of tags

        A <filter> parameter can be passed to build a dictionnary based on some school.
        If specified, then all the tags will have at least one item that is tagged by the school.
                               NOTE
        }
        params do 
          optional :filter, type: String, desc: "id of the tag to filter with"
        end
        post :/ do 
          if params[:filter]
            present dictionnary(params[:filter]), with: Shapter::Entities::Tag, entity_options: entity_options
          else
            present Tag.all, with: Shapter::Entities::Tag, entity_options: entity_options
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
          optional :limit, type: Integer, desc: "Limit the max number of results", default: 40
        end

        post :suggested do 


          resp = reco_tags2(params[:selected_tags],params[:limit])

          present :recommended_tags, resp

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
            present tag, with: Shapter::Entities::Tag, entity_options: entity_options
          else
            error!(tag.errors,500)
          end

        end
        #}}}

        namespace ":tag_id" do 
          before do 
            params do 
              requires :tag_id, type: String, desc: "The tag id"
            end
            @tag = Tag.find(params[:tag_id]) || error!("tag not found", 404)
          end

          #{{{ best comments
          desc "get the best comments for the items linked to this tag"
          params do 
            optional :n_max, type: Integer, desc: "max number of comments to get"
          end
          post :best_comments do 
            n_max = params[:n_max] || 5
            present @tag.best_comments(n_max), with: Shapter::Entities::Comment, entity_options: entity_options
          end
          #}}}

          #{{{ students
          desc "get a list of students from a school"
          post :students do
            #tag = Tag.find(params[:tag_id]) || error!("tag not found",404)
            present :students, @tag.cached_students, with: Shapter::Entities::User, entity_options: entity_options
          end
          #}}}

          #{{{ udpate
          desc "update tag's attributes"
          params do 
            optional :name, type: String, desc: "tag name"
            optional :short_name, type: String, desc: "short name"
            #optional :type, type: String, desc: "tag type"
          end
          put do 
            error!("forbidden",403) unless current_user.shapter_admin

            tag_params = [
              :name,
              :short_name,
              :type,
              :website_url,
              :description,
            ].reduce({}) do |h,p|
              h.merge( params[p] ? {p => params[p]} : {} )
            end

            @tag.update(tag_params)
          end
          #}}}end

          #{{{ show
          desc "show tag"
          post  do 
            present @tag, with: Shapter::Entities::Tag, entity_options: entity_options
          end
          #}}}

          #{{{ destroy
          desc "delete tag"
          delete "" do 
            error!("forbidden",403) unless current_user.shapter_admin
            @tag.destroy
            {:id => @tag.id.to_s, :status => :destroyed}.to_json
          end
        end
        #}}}

      end
    end

  end
end
