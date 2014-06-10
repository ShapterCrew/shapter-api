module Shapter
  module V5
    class ConstructorFunnel < Grape::API
      helpers Shapter::Helpers::FilterHelper
      format :json

      namespace "tags" do
        before do 
          check_user_admin!
        end

        resource ":tag_id" do 
          before do 
            @tag = Tag.find(params[:tag_id]) || error!("tag not found", 404)
          end

          namespace "constructor-funnel" do

            #{{{ put
            desc "set values for the constructor funnel on this tag", {
              :notes => <<-NOTE
            the constructor funnel should be an array of hashes. Each hash has `name`, `tag_ids` & `default_types` keys:

                constructor_funnel_list = [
                  {name: "foo", tag_ids: ["id1","id2"...], default_types: ["type1","type2"]},
                  {name: "bar", tag_ids: ["id1","id3"...], default_types: ["type1","type2"]},
                ]

              NOTE
            }
            params do
              requires :constructor_funnel, type: Array
            end
            put do

              clean_params = params[:constructor_funnel].map{|step|
                {
                  :name          => step["name"],
                  :tag_ids       => step["tag_ids"],
                  :default_types => step["default_types"],
                }
              }

              @tag.constructor_funnel = clean_params
              if @tag.save
                present @tag.constructor_funnel
              else
                error!(@tag.errors.messages)
              end
            end
            #}}}

            #{{{ get
            desc "get values of the constructor funnel list for this tag"
            get do 
              if @tag.constructor_funnel
                present :constructor_funnel, @tag.constructor_funnel
              else
                present :constructor_funnel, nil
              end
            end
            #}}}

            #{{{ delete
            desc "removes the constructor_funnel from this tag"
            delete do 
              @tag.constructor_funnel = nil
              if @tag.save
                present :status, :deleted
              else
                error!(@tag.errors.messages)
              end
            end
            #}}}

          end

        end
      end

      namespace :users do 

        before do 
          check_confirmed_student!
        end

        namespace "me" do 

          namespace "constructor-funnel" do 

            resource ":i" do 
              before do 
                params do 
                  requires :i, type: Integer, desc: "list index, from 1 to n"
                end
              end

              #{{{ get
              desc "get ith items list for users constructor funnel"
              get do 
                tag = current_user.schools.first
                if tag.constructor_funnel

                  if params[:i].to_i > tag.constructor_funnel.size
                    error!("only #{tag.constructor_funnel.size} steps available")
                  else

                  item_ids = tag.constructor_funnel[params[:i].to_i - 1]["tag_ids"]
                  name     = tag.constructor_funnel[params[:i].to_i - 1]["name"]
                  types    = tag.constructor_funnel[params[:i].to_i - 1]["default_types"]

                  items = filter_items2(item_ids)

                  present :total_nb_of_steps, tag.constructor_funnel.size
                  present :name, name
                  present :items, items, with: Shapter::Entities::ItemId, :current_user => current_user
                  present :types, types
                  end
                else
                  present :items, nil
                  present :nb_of_steps, 0
                end
              end
              #}}}

            end

          end

        end
      end

    end
  end
end
