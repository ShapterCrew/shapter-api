module Shapter
  module V3
    class SignupPermissions < Grape::API
      format :json

      before do 
        check_user_admin!
      end

      namespace "signup-permissions"

      #{{{ index
      desc "list all permissions" 
      get do 
        present SignupPermission.all, with: Shapter::Entities::SignupPermission
      end
      #}}}

      #{{{ add a signup permission
      desc "add or update a signup permission"
      params do
        requires :signup_permission, type: Hash do 
          requires :email, type: String, desc: "I'm sure you can guess"
          requires :school_tag_id, type: String, desc: "id of the TAG that will be used as a school"
          optional :firstname, type: String, desc: "users's firstname"
          optional :lastname, type: String, desc: "users's lastname"
        end
      end
      put do 
        tag = Tag.find(params[:signup_permission][:school_tag_id].strip) || error!("tag not found",404)
        perm = SignupPermission.find_or_create_by(email: params[:signup_permission][:email].strip)
        perm.school_name = tag.name

        perm.firstname = params[:signup_permission][:firstname].chomp.strip
        perm.lastname  = params[:signup_permission][:lastname].chomp.strip

        if perm.save
          present perm, with: Shapter::Entities::SignupPermission
        else
          perm.errors.messages.to_json
        end
      end
      #}}}

      resource ":signup_perm_id" do 
        before do 
          params do 
            requires :signup_perm_id, type: String, desc: "id of the permission"
          end
        end

        #{{{ delete a signup permission
        desc "removes a signup permission, based on email"
        delete do 
          SignupPermission.find(params[:signup_perm_id]).destroy
        end
        #}}}

      end

    end
  end
end
