require 'grape-swagger'

class API < Grape::API
  version :v2, using: :accept_version_header, format: :json do
    helpers Shapter::Helpers::Warden

    mount Shapter::PingV2
    mount Shapter::Items
    mount Shapter::ItemTags
    mount Shapter::Comments
    mount Shapter::Tags
    mount Shapter::Users
    add_swagger_documentation(mount_path: '/swagger_doc', markdown: true)
  end
  version :v1, using: :accept_version_header, format: :json do
    helpers Shapter::Helpers::Warden

    mount Shapter::PingV1
    mount Shapter::Items
    mount Shapter::ItemTags
    mount Shapter::Comments
    mount Shapter::Tags
    mount Shapter::Users
    add_swagger_documentation(mount_path: '/swagger_doc', markdown: true)
  end
end
