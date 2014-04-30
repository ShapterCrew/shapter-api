ShapterApi::Application.routes.draw do
  get "home/index"
  devise_for :users
  mount API => '/'
  mount GrapeSwaggerRails::Engine => '/apidoc'

  root :to => "home#index"
end
