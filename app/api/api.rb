require 'grape-swagger'

class API < Grape::API
  version :v4, using: :accept_version_header, format: :json do
    helpers Shapter::Helpers::Warden

    mount Shapter::V4::Ping
    mount Shapter::V4::Items
    mount Shapter::V4::ItemTags
    mount Shapter::V4::Comments
    mount Shapter::V4::Tags
    mount Shapter::V4::Users
    add_swagger_documentation(mount_path: '/swagger_doc', markdown: true)
  end
  version :v3, using: :accept_version_header, format: :json do
    helpers Shapter::Helpers::Warden

    mount Shapter::V3::Ping
    mount Shapter::V3::Items
    mount Shapter::V3::ItemTags
    mount Shapter::V3::Comments
    mount Shapter::V3::Tags
    mount Shapter::V3::Users
    mount Shapter::V3::Diagrams
    mount Shapter::V3::SignupPermissions
    mount Shapter::V3::SignupFunnel
    add_swagger_documentation(mount_path: '/swagger_doc', markdown: true)
  end
end
