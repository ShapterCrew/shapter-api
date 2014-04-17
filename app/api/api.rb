require 'grape-swagger'

class API < Grape::API
  format :json
  version :v1, using: :header, vendor: :shapter

  mount Shapter::Ping
  mount Shapter::Items
  mount Shapter::Items::Comments
  mount Shapter::Tags

  add_swagger_documentation(mount_path: '/swagger_doc', markdown: true)

end
