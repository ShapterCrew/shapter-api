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
          end

          namespace :diag_dims do 

            #{{{ available dimensions
            post :available do 
            end
            #}}}

            #{{{ udpate
            update do 
            end
            #}}}

          end

        end


      end

    end
  end
end

