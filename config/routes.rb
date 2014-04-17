ShapterApi::Application.routes.draw do
  devise_for :users
  mount API => '/'
  mount GrapeSwaggerRails::Engine => '/apidoc'
end
