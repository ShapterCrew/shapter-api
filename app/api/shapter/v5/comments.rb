module Shapter
  module V5
    class Comments < Grape::API
      format :json

      before do 
        check_confirmed_student!
      end

      namespace :items do 
        resource ':item_id' do
          before do 
            params do 
              requires :item_id, type: String, desc: "id of the item to fetch"
            end
          end
          namespace :comments do 

            # {{{ create comment
            desc "comment an item"
            params do
              requires :item_id, type: String, desc: "The item id"
              requires :comment, type: Hash do
                requires :content, type: String, desc: "comment content"
              end
            end
            post :create do
              item = (Item.find(params[:item_id]) || error!("item not found",400) )

              #could be nicer with proper params :permit handling
              content = CGI.escapeHTML(params[:comment][:content] || "")
              c = Comment.new(
                content: content,
                author: current_user,
                item: item,
              )

              if c.save
                c.reload
                present c, with: Shapter::Entities::Comment, :current_user => current_user
                Behave.delay.track current_user.pretty_id, "comment", item: c.item.pretty_id 
              else
                error!(c.errors,400) unless c.valid?
              end
            end
            # }}}

            #{{{ index
            desc "get comments from item"
            get do
              i = Item.find(params[:item_id]) || error!("not found",404)
              ok_school = !(i.tags & current_user.schools).empty?
              ok_admin = current_user.shapter_admin
              error!("access denied",401) unless (ok_admin or ok_school)

              present i.comments, with: Shapter::Entities::Comment, current_user: current_user
            end
            #}}}

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

                old_score = if comment.likers.include?(current_user)
                              1
                            elsif comment.dislikers.include?(current_user)
                              -1
                            else
                              0
                            end

                if s == 0
                  action = "unlike"
                  comment.likers.delete(current_user)
                  comment.dislikers.delete(current_user)
                elsif s == 1
                  action = "like"
                  comment.likers << current_user
                  comment.dislikers.delete(current_user)
                elsif s == -1
                  action = "dislike"
                  comment.dislikers << current_user
                  comment.likers.delete(current_user)
                else
                  error!("invalid score parameter")
                end

                if comment.save
                  present comment, with: Shapter::Entities::Comment, :current_user => current_user
                  if s != old_score
                    Behave.delay.track current_user.pretty_id, action, last_state: old_score, comment_author: comment.author.pretty_id, comment: comment.pretty_id 
                    Behave.delay.track comment.author.pretty_id, "receive like" if s == 1
                  end
                else
                  error!(comment.errors.messages)
                end
              end
              #}}}

            end
          end
        end
      end
    end
  end
end
