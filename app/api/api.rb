require 'grape-swagger'

class API < Grape::API
  format :json
  version :v1, using: :header, vendor: :shapter
  mount Shapter::Ping
  add_swagger_documentation
end
