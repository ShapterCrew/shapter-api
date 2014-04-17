ShapterApi::Application.routes.draw do
  devise_for :users
  mount API => '/'
end
