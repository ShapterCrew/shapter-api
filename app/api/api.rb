require 'grape-swagger'

class API < Grape::API
  version :v7, using: :accept_version_header, format: :json do
    helpers Shapter::Helpers::Warden
    helpers Shapter::Helpers::OptionsHelper

    mount Shapter::V7::Ping
    mount Shapter::V7::Items
    mount Shapter::V7::ItemTags
    mount Shapter::V7::Comments
    mount Shapter::V7::Tags
    mount Shapter::V7::Users
    mount Shapter::V7::Diagrams
    mount Shapter::V7::SignupPermissions
    mount Shapter::V7::SignupFunnel
    mount Shapter::V7::ConstructorFunnel
    mount Shapter::V7::CourseBuilder
    mount Shapter::V7::ConfirmStudents
    mount Shapter::V7::Types
    mount Shapter::V7::SharedDocs
    mount Shapter::V7::EntityAttributes
    mount Shapter::V7::Schools
    add_swagger_documentation(mount_path: '/swagger_doc', markdown: true)
  end
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
end
