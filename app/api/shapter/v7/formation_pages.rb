module Shapter
  module V7
    class FormationPages < Grape::API
      format :json

      before do 
        check_user_login!
      end

      namespace :formations do 

        #{{{ get
        desc "get the formation page from a list of tags. If no record of FormationPage is found, then a new page is automatically generated"
        params do 
          requires :tag_ids, type: Array, desc: "a batch of tags that define the Formation scope"
        end
        post do 
          tag_ids = params[:tag_ids].map{|id| BSON::ObjectId.from_string(id)}
          f = FormationPage.find_by_tags(tag_ids) || FormationPage.new(tag_ids: tag_ids)

          present f, with: Shapter::Entities::FormationPage, entity_options: entity_options
        end
        #}}}

        namespace ":formation_id" do 
          before do 
            params do 
              requires :formation_id, type: String, desc: "id of the formation_page"
            end
            @formation_page = FormationPage.find(params[:formation_id]) || error!("not found",404)
          end

        #{{{ typical users
        desc "get the profile of n typical users for this formation. If the 'randomize' flat is set to true, then a set of profiles will be randomly selected from the best candidates"
        params do 
          optional :randomize, type: Boolean, desc: "randomize results", default: true
          optional :nb, type: Integer, desc: "number of expected results", default: 1
        end
        post :typical_users do 
          nb = (params[:nb] || 1).to_i
          rand = !!params[:randomize]
          present :typical_users, @formation_page.typical_users(nb, rand), with: Shapter::Entities::User, entity_options: entity_options
        end
        #}}}

        end


      end

    end
  end
end
