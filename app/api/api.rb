require 'grape-swagger'

class API < Grape::API
  format :json
  version :v1, using: :header, vendor: :shapter

  mount Shapter::Ping

  before do
    header['Access-Control-Allow-Origin'] = 'localhost'
    header['Access-Control-Request-Method'] = '*'
  end
  add_swagger_documentation

end
