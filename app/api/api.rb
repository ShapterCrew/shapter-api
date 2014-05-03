require 'grape-swagger'

class API < Grape::API
  version :v2, using: :accept_version_header, format: :json do
    helpers Shapter::Helpers::Warden

    mount Shapter::PingV2
    mount Shapter::ItemsV2
    mount Shapter::ItemTags
    mount Shapter::Comments
    mount Shapter::TagsV2
    mount Shapter::Users
    add_swagger_documentation(mount_path: '/swagger_doc', markdown: true)
  end
  version :v1, using: :accept_version_header, format: :json do
    helpers Shapter::Helpers::Warden

    mount Shapter::PingV1
    mount Shapter::ItemsV1
    mount Shapter::ItemTags
    mount Shapter::Comments
    mount Shapter::TagsV1
    mount Shapter::Users
    add_swagger_documentation(mount_path: '/swagger_doc', markdown: true)
  end
end
