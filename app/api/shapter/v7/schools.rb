module Shapter
  module V7
    class Schools < Grape::API
      format :json

      before do 
        check_confirmed_account!
      end

      namespace :schools do 

        #{{{ index
        desc "get a list of schools as an array of tags"
        post do 
          c = Category.find_or_create_by(code: :school)
          present :schools, Tag.where(category: c), with: Shapter::Entities::Tag, entity_options: entity_options
        end
        #}}}

      end

    end
  end
end
