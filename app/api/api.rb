require 'grape-swagger'

class API < Grape::API
  format :json

  #Not sure wether this is very secure or not...
  before do
    header['Access-Control-Allow-Origin'] = '*'
    header['Access-Control-Request-Method'] = '*'
  end

  version :v1, using: :header, vendor: :shapter
  mount Shapter::Ping
  add_swagger_documentation
end
