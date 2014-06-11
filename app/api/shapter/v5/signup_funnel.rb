module Shapter
  module V5
    class SignupFunnel < Grape::API
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

          namespace "signup-funnel" do

            #{{{ put
            desc "set values for the signup funnel on this tag", {
              :notes => <<-NOTE
            the signup funnel should be an array of hashes. Each hash has `name` and `tag_ids` keys:

                signup_funnel_list = [
                  {name: "foo", tag_ids: ["id1","id2"...]},
                  {name: "bar", tag_ids: ["id1","id3"...]},
                ]

              NOTE
            }
            params do
              requires :signup_funnel, type: Array
            end
            put do

              clean_params = params[:signup_funnel].map{|step|
                {
                  :name => step["name"],
                  :tag_ids => step["tag_ids"],
                }
              }

              @tag.signup_funnel = clean_params
              if @tag.save
                present @tag.signup_funnel
              else
                error!(@tag.errors.messages)
              end
            end
            #}}}

            #{{{ get
            desc "get values of the signup funnel list for this tag"
            get do 
              if @tag.signup_funnel
                present :signup_funnel, @tag.signup_funnel
              else
                present :signup_funnel, nil
              end
            end
            #}}}

            #{{{ delete
            desc "removes the signup_funnel from this tag"
            delete do 
              @tag.signup_funnel = nil
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

          namespace "signup-funnel" do 

            resource ":i" do 
              before do 
                params do 
                  requires :i, type: Integer, desc: "list index, from 1 to n"
                end
              end

              #{{{ get
              desc "get ith items list for users signup funnel"
              get do 
                tag = current_user.schools.first
                if tag.signup_funnel

                  if params[:i].to_i > tag.signup_funnel.size
                    error!("only #{tag.signup_funnel.size} steps available")
                  else

                  item_ids = tag.signup_funnel[params[:i].to_i - 1]["tag_ids"]
                  name     = tag.signup_funnel[params[:i].to_i - 1]["name"]

                  items = filter_items2(item_ids)

                  present :total_nb_of_steps, tag.signup_funnel.size
                  present :name, name
                  present :items, items, with: Shapter::Entities::ItemId, :current_user => current_user, with_tags: true
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
