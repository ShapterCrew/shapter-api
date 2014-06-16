class HomeController < ApplicationController
  def index

    
    require 'net/http'

    uri = URI("https://graph.facebook.com/#{User.where(provider: "facebook").last.uid}/friends")

    args = {access_token: FACEBOOK_APP_TOKEN}
    uri.query = URI.encode_www_form(args)
    resp = Net::HTTP.get_response(uri)
    @test =  JSON.parse(resp.body)["data"]

    @uid = current_user.uid

    redirect_to "http://shapter.com/#/browse" if Rails.env.production?
  end
end
