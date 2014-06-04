ShapterApi::Application.routes.draw do
  get "home/index"
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks"}
  mount API => '/'
  mount GrapeSwaggerRails::Engine => '/apidoc'

  root :to => "home#index"
end
