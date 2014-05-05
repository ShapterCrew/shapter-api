require 'grape-swagger'

class API < Grape::API
  version :v2, using: :accept_version_header, format: :json do
    helpers Shapter::Helpers::Warden

    mount Shapter::PingV2
    mount Shapter::ItemsV2
    mount Shapter::ItemTagsV2
    mount Shapter::CommentsV2
    mount Shapter::TagsV2
    mount Shapter::UsersV2
    add_swagger_documentation(mount_path: '/swagger_doc', markdown: true)
  end
  version :v1, using: :accept_version_header, format: :json do
    helpers Shapter::Helpers::Warden

    mount Shapter::PingV1
    mount Shapter::ItemsV1
    mount Shapter::ItemTagsV1
    mount Shapter::CommentsV1
    mount Shapter::TagsV1
    mount Shapter::UsersV1
    add_swagger_documentation(mount_path: '/swagger_doc', markdown: true)
  end
end
