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
                :author => current_user,
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
                @shared_doc = @item.shared_docs.find(params[:doc_id]) || error!("doc not found",404)
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
                @item.save
                present :status, :deleted
              end
              #}}}

              #{{{ score
              desc "like, or dislike a document"
              params do 
                requires :score, type: Integer, desc: "score"
              end
              put :score do 
                s = params[:score].to_i

                old_score = if @shared_doc.likers.include?(current_user)
                              1
                            elsif @shared_doc.dislikers.include?(current_user)
                              -1
                            else
                              0
                            end

                if s == 0
                  action = "unlike document"
                  @shared_doc.likers.delete(current_user)
                  @shared_doc.dislikers.delete(current_user)
                elsif s == 1
                  action = "like document"
                  @shared_doc.likers << current_user
                  @shared_doc.dislikers.delete(current_user)
                elsif s == -1
                  action = "dislike document"
                  @shared_doc.dislikers << current_user
                  @shared_doc.likers.delete(current_user)
                else
                  error!("invalid score parameter")
                end

                if @shared_doc.save
                  present @shared_doc, with: Shapter::Entities::SharedDoc, :current_user => current_user
                  if s != old_score
                    Behave.delay.track current_user.pretty_id, action, last_state: old_score, document_author: @shared_doc.author.pretty_id, shared_doc: @shared_doc.pretty_id 
                    Behave.delay.track @shared_doc.author.pretty_id, "receive document like" if s == 1
                  end
                else
                  error!(comment.errors.messages)
                end
              end
              #}}}

              #{{{ countDl
              desc "add +1 to download counter"
              post :countDl do
                @shared_doc.inc(dl_count: 1) 
                present :count, @shared_doc.dl_count
              end
              #}}}

            end
          end
        end
      end

    end
  end
end
