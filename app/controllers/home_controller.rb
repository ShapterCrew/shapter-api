class HomeController < ApplicationController
  def index
    redirect_to "http://shapter.com/#/browse" if Rails.env.production?
  end
end
