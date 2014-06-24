require 'grape-swagger'

class API < Grape::API
  version :v6, using: :accept_version_header, format: :json do
    helpers Shapter::Helpers::Warden

    mount Shapter::V6::Ping
    mount Shapter::V6::Items
    mount Shapter::V6::ItemTags
    mount Shapter::V6::Comments
    mount Shapter::V6::Tags
    mount Shapter::V6::Users
    mount Shapter::V6::Diagrams
    mount Shapter::V6::SignupPermissions
    mount Shapter::V6::SignupFunnel
    mount Shapter::V6::ConstructorFunnel
    mount Shapter::V6::CourseBuilder
    mount Shapter::V6::ConfirmStudents
    mount Shapter::V6::Types
    mount Shapter::V6::SharedDocs
    add_swagger_documentation(mount_path: '/swagger_doc', markdown: true)
  end
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
end
