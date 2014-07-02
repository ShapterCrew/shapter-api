module Shapter
  module V7
    class Comments < Grape::API
      format :json

      before do 
        check_confirmed_student!
      end

      namespace :users do 
        namespace ":user_id" do 
          before do 
            params do 
              requires :user_id, type: String, desc: "id of the user"
            end
            @user = User.find(params[:user_id]) || error!("user not found",404)
          end

          namespace :comments do 
            #{{{ get comments
            desc "get user's comments"
            get do 
              present :comments, @user.comments, with: Shapter::Entities::Comment, entity_options: entity_options
            end
            #}}}
          end

        end
      end

      namespace :items do 
        resource ':item_id' do
          before do 
            params do 
              requires :item_id, type: String, desc: "id of the item to fetch"
            end
            @item = Item.find(params[:item_id]) || error!("item not found",404)
          end
          namespace :comments do 

            # {{{ create comment
            desc "comment an item"
            params do
              requires :comment, type: Hash do
                requires :content, type: String, desc: "comment content"
              end
            end
            post :create do
              error!("forbidden",401) unless @item.user_can_view_comments?(current_user)

              #could be nicer with proper params :permit handling
              content = CGI.escapeHTML(params[:comment][:content] || "")
              c = Comment.new(
                content: content,
                author: current_user,
                item: @item,
              )

              if c.save
                c.reload
                present c, with: Shapter::Entities::Comment, entity_options: entity_options
                Behave.delay.track current_user.pretty_id, "comment", item: c.item.pretty_id 
              else
                error!(c.errors,400) unless c.valid?
              end
            end
            # }}}

            #{{{ index
            desc "get comments from item"
            get do
              ok_school = !(@item.tags & current_user.schools).empty?
              ok_admin = current_user.shapter_admin
              error!("access denied",401) unless (ok_admin or ok_school)

              present @item.comments, with: Shapter::Entities::Comment, entity_options: entity_options
            end
            #}}}

            resource ':comment_id' do
              before do 
                params do 
                  requires :comment_id, type: String, desc: "id of the comment"
                end
                @comment = (@item.comments.find(params[:comment_id]) || error!("comment not found"))
              end

              #{{{ update
              desc "updates comment"
              params do 
                requires :comment, type: Hash do 
                  requires :content, type: String, desc: "new content of the comment"
                end
              end
              put do 
                error!("forbidden") unless (@comment.author == current_user or current_user.shapter_admin)
                if @comment.update_attribute(:content, params[:comment][:content])
                  present @comment, with: Shapter::Entities::Comment, entity_options: entity_options
                else
                  error!(@comment.errors)
                end
              end
              #}}}

              # {{{ destroy 
              desc "destroy a comment"
              delete do
                error!("forbidden") unless (@comment.author == current_user or current_user.shapter_admin)
                @comment.destroy
                {
                  :comment => {:id => @comment.id.to_s, :status => :destroyed}
                }
              end
              # }}}

              # {{{ score
              desc "Score a comment. pass -1 to dislike, 0 to ignore and 1 to like"
              params do 
                requires :score, type: Integer, desc: "score"
              end
              put :score do 
                s = params[:score].to_i

                old_score = if @comment.likers.include?(current_user)
                              1
                            elsif @comment.dislikers.include?(current_user)
                              -1
                            else
                              0
                            end

                if s == 0
                  action = "unlike"
                  @comment.likers.delete(current_user)
                  @comment.dislikers.delete(current_user)
                elsif s == 1
                  action = "like"
                  @comment.likers << current_user
                  @comment.dislikers.delete(current_user)
                elsif s == -1
                  action = "dislike"
                  @comment.dislikers << current_user
                  @comment.likers.delete(current_user)
                else
                  error!("invalid score parameter")
                end

                if @comment.save
                  present @comment, with: Shapter::Entities::Comment, entity_options: entity_options
                  if s != old_score
                    Behave.delay.track current_user.pretty_id, action, last_state: old_score, comment_author: @comment.author.pretty_id, comment: @comment.pretty_id 
                    Behave.delay.track @comment.author.pretty_id, "receive like" if s == 1
                  end
                else
                  error!(@comment.errors.messages)
                end
              end
              #}}}

              #{{{ likers
              desc "get a list of user that like the comment"
              get :likers do 
                present :likers, @comment.likers, with: Shapter::Entities::User, entity_options: entity_options
              end
              #}}}

              #{{{ dislikers
              desc "get a list of user that dislike the comment"
              get :dislikers do 
                present :dislikers, @comment.dislikers, with: Shapter::Entities::User, entity_options: entity_options
              end
              #}}}

            end
          end
        end
      end
    end
  end
end
