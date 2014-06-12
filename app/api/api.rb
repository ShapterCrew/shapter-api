require 'grape-swagger'

class API < Grape::API
  version :v5, using: :accept_version_header, format: :json do
    helpers Shapter::Helpers::Warden

    mount Shapter::V5::Ping
    mount Shapter::V5::Items
    mount Shapter::V5::ItemTags
    mount Shapter::V5::Comments
    mount Shapter::V5::Tags
    mount Shapter::V5::Users
    mount Shapter::V5::Diagrams
    mount Shapter::V5::SignupPermissions
    mount Shapter::V5::SignupFunnel
    mount Shapter::V5::ConstructorFunnel
    mount Shapter::V5::CourseBuilder
    mount Shapter::V5::ConfirmStudents
    mount Shapter::V5::Types
    mount Shapter::V5::SharedDocs
    add_swagger_documentation(mount_path: '/swagger_doc', markdown: true)
  end
  version :v4, using: :accept_version_header, format: :json do
    helpers Shapter::Helpers::Warden

    mount Shapter::V4::Ping
    mount Shapter::V4::Items
    mount Shapter::V4::ItemTags
    mount Shapter::V4::Comments
    mount Shapter::V4::Tags
    mount Shapter::V4::Users
    mount Shapter::V4::Diagrams
    mount Shapter::V4::SignupPermissions
    mount Shapter::V4::SignupFunnel
    mount Shapter::V4::CourseBuilder
    mount Shapter::V4::ConfirmStudents
    add_swagger_documentation(mount_path: '/swagger_doc', markdown: true)
  end
end
