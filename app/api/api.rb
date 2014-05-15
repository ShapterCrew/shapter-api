require 'grape-swagger'

class API < Grape::API
  version :v3, using: :accept_version_header, format: :json do
    helpers Shapter::Helpers::Warden

    mount Shapter::V3::Ping
    mount Shapter::V3::Items
    mount Shapter::V3::ItemTags
    mount Shapter::V3::Comments
    mount Shapter::V3::Tags
    mount Shapter::V3::Users
    add_swagger_documentation(mount_path: '/swagger_doc', markdown: true)
  end
  version :v2, using: :accept_version_header, format: :json do
    helpers Shapter::Helpers::Warden

    mount Shapter::V2::Ping
    mount Shapter::V2::Items
    mount Shapter::V2::ItemTags
    mount Shapter::V2::Comments
    mount Shapter::V2::Tags
    mount Shapter::V2::Users
    add_swagger_documentation(mount_path: '/swagger_doc', markdown: true)
  end
end
