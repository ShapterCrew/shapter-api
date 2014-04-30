class HomeController < ApplicationController
  def index
    redirect_to "http://shapter.com" if Rails.env.production?
  end
end
