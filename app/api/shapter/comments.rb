module Shapter
  class Comments < Items
    format :json

    namespace :items do 
      resource ':item_id' do
        namespace :comments do 

          # {{{ create comment
          desc "comment an item"
          params do
            requires :content, type: String, desc: "The comment content"
            requires :item_id, type: String, desc: "The item id"
          end
          post :create do
            {
              :comment => {:id => :fake_id_of_comment, :status => :created}
            }
          end
          # }}}

          resource ':comment_id' do

            # {{{ destroy 
            desc "destroy a comment"
            params do 
              requires :comment_id, type: String, desc: "id of the comment"
              requires :item_id, type: String, desc: "The item id"
            end
            delete do
              {
                :comment => {:id => 123, :status => :created}
              }
            end
            # }}}

            # {{{ score
            desc "Score a comment. pass -1 to dislike, 0 to ignore and 1 to like"
            params do 
              requires :score, type: Integer, desc: "score"
              requires :comment_id, type: String, desc: "id of the comment"
              requires :item_id, type: String, desc: "The item id"
            end
            put :score do 
              if [-1,0,1].include? params[:score].to_i
                {
                  :item_id => params[:item_id],
                  :comment_id => params[:comment_id],
                  :score => params[:score],
                }
              else
                {error: "wrong score number"}
              end
            end
            #}}}

          end
        end
      end
    end
  end
end
