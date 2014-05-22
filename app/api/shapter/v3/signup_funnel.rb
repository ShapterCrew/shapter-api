module Shapter
  module V3
    class SignupFunnel < Grape::API
      format :json

      before do 
        check_user_admin!
      end

      namespace "tags" do

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
              @tag.signup_funnel_tag_list = params[:signup_funnel]
              if @tag.save
              present @tag.signup_funnel_tag_list
              else
                error!(@tag.errors.messages)
              end
            end
            #}}}

            #{{{ get
            desc "get values of the signup funnel list for this tag"
            get do 
              if @tag.signup_funnel_tag_list
                present :signup_funnel, @tag.signup_funnel_tag_list
              else
                present :signup_funnel, nil
              end
            end
            #}}}

            #{{{ delete
            desc "removes the signup_funnel_tag_list from this tag"
            delete do 
              @tag.signup_funnel_tag_list = nil
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

    end
  end
end
