module Shapter
  module V7
    class Categories < Grape::API
      format :json

      before do 
        check_confirmed_account!
      end

      namespace :categories do 

        desc "index: get a list  of categories"
        post do 
          present :categories, Category.all, with: Shapter::Entities::Category, entity_options: entity_options
        end

      end
    end
  end
end
