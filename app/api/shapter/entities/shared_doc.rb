module Shapter
  module Entities
    class SharedDoc < Grape::Entity
      expose :pretty_id, as: :id
      expose :name       , if: lambda{ |u,o| o[:entity_options]["shared_doc"][:name]}
      expose :description, if: lambda{ |u,o| o[:entity_options]["shared_doc"][:description]}
      expose :file_url   , as: :file                     , if: lambda{ |u,o| o[:entity_options]["shared_doc"][:file]}
      expose :dl_count   , as: :dlCount                  , if: lambda{ |u,o| o[:entity_options]["shared_doc"][:dlCount]}
      expose :author     , using: Shapter::Entities::User, if: lambda{ |u,o| o[:entity_options]["shared_doc"][:author]}
    end
  end
end
