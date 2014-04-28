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
            requires :item_id, type: String, desc: "The item id"
            requires :comment, type: Hash do
              requires :content, type: String, desc: "comment content"
              requires :work_score, type: Integer, desc: "workload score, from 1 to 100"
              requires :quality_score, type: Integer, desc: "qualityload score, from 1 to 100"
            end
          end
          post :create do
            item = (Item.find(params[:item_id]) || error!("item not found",400) )

            #could be nicer with proper params :permit handling
            content = CGI.escapeHTML(params[:comment][:content] || "")
            c = Comment.new(
              content: content,
              author: current_user,
              work_score: params[:comment][:work_score],
              quality_score: params[:comment][:quality_score],
            )

            error!(c.errors,400) unless c.valid?

            item.comments << c
            item.save

            c.reload
            present c, with: Shapter::Entities::Comment, :current_user => current_user
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
              item = (Item.find(params[:item_id]) || error!("item not found"))
              comment = (item.comments.find(params[:comment_id]) || error!("comment not found"))
              error!("forbidden") unless (comment.author == current_user or current_user.shapter_admin)
              comment.destroy
              {
                :comment => {:id => comment.id.to_s, :status => :destroyed}
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
              item = (Item.find(params[:item_id]) || error!("item not found"))
              comment = (item.comments.find(params[:comment_id]) || error!("comment not found"))
              s = params[:score].to_i

              if s == 0
                comment.likers.delete(current_user)
                comment.dislikers.delete(current_user)
              elsif s == 1
                comment.likers << current_user
                comment.dislikers.delete(current_user)
              elsif s == -1
                comment.dislikers << current_user
                comment.likers.delete(current_user)
              else
                error!("invalid score parameter")
              end
              comment.save
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
