module Shapter
  class Comments < Items
    format :json

    before do 
      check_user_login!
    end

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
            item = (Item.find(params[:item_id]) rescue error!("not found") )
            item.comments << (c= Comment.new(:content => params[:content]))
            item.save

            {
              :comment => {:status => :created, :id => c.id}
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
              item = (Item.find(params[:item_id]) rescue error!("item not found"))
              comment = (item.comments.find(params[:comment_id]) rescue error!("comment not found"))
              error!("forbidden") unless (comment.author == current_user or current_user.shapter_admin)
              comment.destroy
              {
                :comment => {:id => comment.id, :status => :destroyed}
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
              item = (Item.find(params[:item_id]) rescue error!("item not found"))
              comment = (item.comments.find(params[:comment_id]) rescue error!("comment not found"))
              s = params[:score].to_i

              if s == 0
                item.likers.delete(current_user)
                item.dislikers.delete(current_user)
              elsif s == 1
                item.likers << current_user
                item.dislikers.delete(current_user)
              elsif s == -1
                item.dislikers << current_user
                item.likers.delete(current_user)
              else
                error!("invalid score parameter")
              end
              item.save
              {
                :item_id => item.id,
                :comment_id => comment.id,
                :score => s,
              }
            end
            #}}}

          end
        end
      end
    end
  end
end
