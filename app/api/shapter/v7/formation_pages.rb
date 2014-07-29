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

      end

    end
  end
end
