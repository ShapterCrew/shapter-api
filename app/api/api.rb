require 'grape-swagger'

class API < Grape::API
  format :json
  version :v1, using: :header, vendor: :shapter

  before do
    header['Access-Control-Allow-Origin'] = (Rails.env.production? ? 'localhost' : "*")
    header['Access-Control-Request-Method'] = '*'
  end

  mount Shapter::Ping
  mount Shapter::Tags
  mount Shapter::Comments

  add_swagger_documentation(mount_path: '/apidoc', markdown: true)

end
