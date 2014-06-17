require 'faraday'
module Facebookable
  extend ActiveSupport::Concern

  class FbConnector
    class << self
      def conn
        Faraday.new(:url => 'https://graph.facebook.com') do |faraday|
          faraday.request  :url_encoded             # form-encode POST params
          faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
          faraday.params["access_token"] = FACEBOOK_APP_TOKEN
        end
      end
    end
  end

  included do 
    field :facebook_email, type: String
    field :provider, type: String
    field :uid, type: String

    def image
      provider == "facebook" ? "http://graph.facebook.com/#{uid}/picture" : nil
    end

    def fb_friends
      Rails.cache.fetch("usrFbFriends|#{id}", expires_in: 1.minutes) do 
        provider == "facebook" ? JSON.parse(FbConnector.conn.get("/#{uid}/friends").body)["data"] : []
      end
    end

    def fb_friend_ids
      provider == "facebook" ? fb_friends.map{|h| h["id"]} : []
    end

    def friends
      Rails.cache.fetch("usrFriends|#{id}", expires_in: 1.minutes) do 
        provider == "facebook" ? User.any_in(uid: fb_friend_ids) : []
      end
    end

    def is_friend_with? user
      friends.include? user
    end

  end

  module ClassMethods
    def find_for_facebook_oauth(auth)
      fake_email = "fake.#{auth.info.email}"

      #if user = User.find_by(email: auth.info.email, provider: nil)
      #  user.update_attribute(:uid, auth.uid)
      #  user.update_attribute(:provider, auth.provider)
      #  user.update_attribute(:facebook_email , auth.info.email)
      #  user
      #else

      where(auth.slice(:provider, :uid)).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.facebook_email = auth.info.email
        user.email = fake_email #user.email = auth.info.email
        user.password = Devise.friendly_token[0,20]
        user.firstname = auth.info.first_name   # assuming the user model has a name
        user.lastname  = auth.info.last_name   # assuming the user model has a name
        #user.image = auth.info.image # assuming the user model has an image
      end

      #end
    end

    def new_with_session(params, session)
      super.tap do |user|
        if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
          user.email = data["email"] if user.email.blank?
        end
      end
    end
  end

end
