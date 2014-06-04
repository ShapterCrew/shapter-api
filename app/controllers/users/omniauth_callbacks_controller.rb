class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      #render json: resource.sign_in_json, location: after_sign_in_path_for(resource)
      #sign_in(@user, resource)
      #render json: resource.sign_in_json, location: after_sign_in_path_for(resource)
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
      #render json: {status: :failed}
    end
  end
end
