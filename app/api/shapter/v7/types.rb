module Shapter
  module V7
    class Types < Grape::API
      format :json

      helpers Shapter::Helpers::FilterHelper

      before do 
        check_confirmed_student!
      end

      namespace :types do 

        #{{{ index
        desc "get a complete list of tag types"
        get do
          present :types, Tag.all.map(&:type).compact.uniq
        end
        #}}}

      end
    end

  end
end

