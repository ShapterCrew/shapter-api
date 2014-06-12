module Shapter
  module V5
    class SharedDocs < Grape::API
      format :json

      before do 
        check_confirmed_student!
      end

      namespace :items do 
        namespace ':item_id' do 

          before do 
            params do 
              requires :item_id, type: String, desc: "id of the item"
            end
            @item = Item.find(params[:item_id]) || error!("item not found",404)
          end

          namespace :sharedDocs do 

            #{{{ index
            desc "get a list of docs for this item"
            get do 
              present :shared_docs, @item.shared_docs, with: Shapter::Entities::SharedDoc
            end
            #}}}

            #{{{ create
            desc "create a doc for this item"
            params do 
              requires :sharedDoc, type: Hash do
                requires :name, type: String, desc: "name of the document"
                optional :description, type: String, desc: "description"
                requires :file, desc: "file"
              end
            end
            post do
              clean_p = {
                :name => params[:sharedDoc][:name],
                :description => params[:sharedDoc][:description],
                :file => params[:sharedDoc][:file],
                :item => @item,
              }

              doc = SharedDoc.new(clean_p)

              if doc.save
                present doc, using: Shapter::Entities::SharedDoc
              else
                error!(doc.errors.messages)
              end
            end
            #}}}

            namespace ':doc_id' do 
              before do 
                params do 
                  requires :doc_id, type: String, desc: "id of the document"
                end
                @shared_doc = SharedDoc.find(params[:doc_id]) || error!("doc not found",404)
              end

              #{{{ get
              desc "get the shared_doc"
              get do 
                present @shared_doc, with: Shapter::Entities::SharedDoc
              end
              #}}}

              #{{{ update
              desc "update document attributes"
              params do
                optional :name, type: String, desc: "name of the document"
                optional :description, type: String, desc: "description"
                optional :file, desc: "file"
              end
              put do 
                clean_p = [
                  (name = params[:sharedDoc][:name]) ? {name: name} : {},
                  (description = params[:sharedDoc][:description]) ? {description: description} : {},
                  (file = params[:sharedDoc][:file]) ? {file: file} : {},
                ].reduce(&:merge)

                if @shared_doc.update_attributes(clean_p)
                  present @sharedDoc, with: Shapter::Entities::SharedDoc
                else
                  error!(@shared_doc.errors.messages)
                end
              end
              #}}}

              #{{{ delete
              desc "delete document"
              delete do 
                @shared_doc.destroy
                present :status, :deleted
              end
              #}}}

            end

          end
        end
      end

    end
  end
end
