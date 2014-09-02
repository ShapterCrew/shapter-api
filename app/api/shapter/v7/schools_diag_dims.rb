module Shapter
  module V7
    class SchoolsDiagDims < Grape::API
      format :json

      before do 
        check_user_admin!
      end

      namespace :schools do 

        namespace ':school_id' do 
          before do 
            params do 
              requires :school_id, desc: "id of the school (i.e. id of the school tag)"
            end
            @tag = Tag.find(params[:school_id]) || error!("not found",404)
            error!("tag is no school",500) unless @tag.category_code == "school"
          end

          namespace :diag_dims do 

            #{{{ available dimensions
            desc "get the exhaustive list of available dimensions"
            post :available do 
              present :available_dimensions, Diagram.names.each_with_index.to_a.map(&:reverse).to_h
            end
            #}}}

            #{{{ udpate
            desc "set the custom diagram dimensions for this school."
            params do 
              requires :index_array, type: Array, desc: "an array of dimensions indices. Example: default dimensions would be [0,4,5,6,7,9,12]. Please see the /schools/:id/available for details about the dimensions"
            end
            put do 
              @tag.custom_diag_dims = params[:index_array].map(&:to_i).uniq
              if @tag.save
                present @tag, with: Shapter::Entities::Tag, entity_options: entity_options
              else
                error(@tag.errors)
              end
            end
            #}}}

          end

        end


      end

    end
  end
end

