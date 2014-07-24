module Shapter
  module V7
    class Schools < Grape::API
      format :json

      namespace :schools do 

        #{{{ index 
        desc "get a list of schools"
        post :index do 
          present :schools, Tag.where(category: Category.find_by(code: "school")), with: Shapter::Entities::School, entity_options: entity_options
        end
        #}}}

        namespace ':school_id' do 

          before do 
            params do 
              requires :school_id, type: String, desc: "id of the school(which is a tag)"
            end
            @school_tag = Tag.find(params[:school_id]) || error!("school not found", 404)
            error!("selected tag is no school",406) unless @school_tag.is_school?
          end

          #{{{ get
          desc "get a school"
          post do
            present @school_tag, with: Shapter::Entities::School, entity_options: entity_options
          end
          #}}}

          #{{{ update
          #}}}

        end

      end
    end
  end
end
