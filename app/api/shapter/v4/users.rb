module Shapter
  module V4
    class Users < Grape::API
      format :json

      before do 
        check_user_login!
      end

      namespace :users do 

        namespace :me do 

          #{{{ /users/me
          get do 
            present current_user, with: Shapter::Entities::User, :current_user => current_user
          end
          #}}}

          #{{{ comment pipe
          desc "comment pipe : what are the items to comment ?"
          params do 
            optional :n, type: Integer, default: 5, desc: "number of items to get"
          end
          get "comment-pipe" do 
            n = params[:n] || 5
            r = current_user.items.not.where("comments.author_id" => current_user.id).desc(:requires_comment_score).take(n)
            present :commentable_items, r , with: Shapter::Entities::ItemShort, :show_interested_users => true
          end
          #}}}

          #{{{ confirm_student
          desc "confirm student with different email address"
          params do 
            requires :email   , type: String, desc: "school email to validate student with"
            optional :password, type: String, desc: "If the email is already recorded in database, then a password will be asked to confirm ownership"
          end
          post :confirm_student_email do 
            email   = params[:email]
            pass    = params[:password]
            schools = User.schools_for(email)

            # End now if email is no student email
            error!("unrecognized student email format") if schools.empty?

            if u = User.find_by(email: email) 
              error!("existing account,please provide a password") if pass.blank?
              error!("wrong email/password combination") unless u.valid_password?(pass)

              # Old account has been found, email gives schools and ownership is verified through password confirmation

              this_user_id = current_user.id.dup

              u.update_attribute(:uid, current_user.uid)
              u.update_attribute(:provider,  current_user.provider)
              u.update_attribute(:facebook_email, current_user.email)

              User.find(this_user_id).destroy

              present :email, email
              present :status, :changed

            else

              # No account is found using the provided email, and provided email gives schools
              current_user.update_attribute(:email, email)
              current_user.update_attribute(:confirmed_at, nil)
              current_user.save
              current_user.send_confirmation_instructions
              present :email, email
              present :status, "sent confirmation email"

            end

          end
          #}}}

        end

        resource ":user_id" do 

          #{{{ get user
          get do 
            user = User.find(params[:user_id]) || error!("not found",404)
            present user, with: Shapter::Entities::User, :current_user => current_user
          end
          #}}}

        end
      end

    end
  end
end
