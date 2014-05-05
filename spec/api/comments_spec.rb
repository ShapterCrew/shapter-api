require 'spec_helper'

describe Shapter::CommentsV2 do 

  before(:each) do 
    Item.delete_all
    User.delete_all
    @item = FactoryGirl.create(:item)
    @user = FactoryGirl.create(:user)
    @comment = FactoryGirl.build(:comment)
    @comment.author = @user
  end


  # {{{ create
  describe :create do 
    it "should require login" do 
      post "/items/#{@item.id}/comments/create", :comment => @comment.attributes
      response.status.should == 401
      response.body.should == {error: "please login"}.to_json
    end

    context "when logged in" do 

      before do 
        login(@user)
      end

      it "errors if item is not found" do 
        post "/items/not_valid/comments/create", :comment => @comment.attributes
        response.status.should == 400
        response.body.should == {error: "item not found"}.to_json
      end

      it "should create comment" do 
        post "/items/#{@item.id}/comments/create", :comment => @comment.attributes
        response.status.should == 201
        h = JSON.parse(response.body)
        h.has_key?("content").should be_true
        h.has_key?("id").should be_true

        @item.reload
        @item.comments.last.content.should == @comment.content
      end

      it "validates presence of content" do 
        post "/items/#{@item.id}/comments/create", :comment => @comment.attributes.merge(:content => nil)
        response.status.should == 400
      end

      it "validates presence of work_score" do 
        post "/items/#{@item.id}/comments/create", :comment => @comment.attributes.merge(:work_score => nil)
        response.status.should == 400
      end

      it "validates presence of quality_score" do 
        post "/items/#{@item.id}/comments/create", :comment => @comment.attributes.merge(:quality_score => nil)
        response.status.should == 400
      end

      it "validates value of work_score" do 
        post "/items/#{@item.id}/comments/create", :comment => @comment.attributes.merge(:work_score => 600)
        response.status.should == 400
      end

      it "validates value of quality_score" do 
        post "/items/#{@item.id}/comments/create", :comment => @comment.attributes.merge(:quality_score => 600)
        response.status.should == 400
      end

    end

  end
  #}}}

  #{{{ destroy
  describe :destroy do
    it "should require login" do 
      delete "/items/123/comments/#{@comment.id}"
      response.status.should == 401
      response.body.should =~ /error/
    end

    describe "should check if current_user is either admin, or comment owner" do 
      before do 
        @item.comments << @comment
        @item.save
        @user2 = FactoryGirl.build(:user)
        @user2.email = 'foo2@bar2.com'
        @user2.save
      end

      context :shapter_admin do 
        before do 
          User.any_instance.stub(:shapter_admin).and_return(true)
        end

        it "authorizes admin" do 
          login(@user2)
          @item.comments.size.should == 1
          delete "items/#{@item.id}/comments/#{@comment.id}"
          @response.body.should == {:comment => {:id => @comment.id.to_s, :status => :destroyed}}.to_json
          @item.reload
          @item.comments.size.should == 0
        end
      end

      context :simple_user do 
        before do 
          User.any_instance.stub(:shapter_admin).and_return(false)
        end

        it "authorizes owner" do 
          login(@user)
          @item.comments.size.should == 1
          delete "items/#{@item.id}/comments/#{@comment.id}"
          @response.status.should == 200
          @item.reload
          @item.comments.size.should == 0
        end

        it "doesn't authorize other user" do 
          login(@user2)
          @item.comments.size.should == 1
          delete "items/#{@item.id}/comments/#{@comment.id}"
          @response.status.should == 500
          @response.body.should == {error: "forbidden"}.to_json
          @item.reload
          @item.comments.size.should == 1
        end
      end
    end

  end
  #}}}

  #{{{ score
  describe :score do 
    it "should require login" do 
      put "items/1234/comments/#{@comment.id}/score", :score => 1
      response.status.should == 401
      response.body.should =~ /error/
    end

    context "when logged in" do 
      before do 
        login(@user)
        @item.comments << @comment
        @item.save
      end

      it "should add to likers when +1" do 
        put "items/#{@item.id}/comments/#{@comment.id}/score", :score => 1
        @comment.reload
        @comment.likers.include?(@user).should be_true
        @comment.dislikers.include?(@user).should be_false
      end

      it "should add to dislikers when -1" do 
        put "items/#{@item.id}/comments/#{@comment.id}/score", :score => -1
        @comment.reload
        @comment.likers.include?(@user).should be_false
        @comment.dislikers.include?(@user).should be_true
      end

      it "should remove from like/dislikers when 0" do 
        put "items/#{@item.id}/comments/#{@comment.id}/score", :score => 1
        put "items/#{@item.id}/comments/#{@comment.id}/score", :score => 0
        @comment.reload
        @comment.likers.include?(@user).should be_false
        @comment.dislikers.include?(@user).should be_false
      end

      it "should error when score is not in [-1,0,1]" do 
        put "items/#{@item.id}/comments/#{@comment.id}/score", :score => 3
        @response.status.should == 500
        @response.body.should == {error: "invalid score parameter"}.to_json
      end

    end

  end
  #}}}

end
