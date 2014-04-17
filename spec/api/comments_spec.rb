require 'spec_helper'

describe Shapter::Comments do 

  before(:each) do 
    Item.delete_all
    User.delete_all
    @item = FactoryGirl.create(:item)
    @comment = FactoryGirl.create(:comment)
    @user = FactoryGirl.create(:user)
  end

  describe :create do 
    it "should require login" do 
      post "/items/#{@item.id}/comments/create", :content => @valid_content
      response.status.should == 401
      response.body.should =~ /error/
    end

    it "errors if item is not found" do 
      sign_in :user, @user
      post "/items/not_valid/comments/create", :content => @valid_content
      response.status.should == 500
      response.body.should =~ /not found/
    end

    it "should create comment" do 
      pending
    end

  end

  describe :destroy do
    it "should require login" do 
      delete "/items/123/comments/#{@comment.id}"
      response.status.should == 401
      response.body.should =~ /error/
    end

    it "should check if current_user is either admin, or comment owner" do 
      pending
    end

    it "should delete comment" do 
      pending
    end
  end

  describe :score do 
    it "should require login" do 
      put "items/1234/comments/#{@comment.id}/score", :score => 1
      response.status.should == 401
      response.body.should =~ /error/
    end

    it "should add to likers when +1" do 
      pending
    end

    it "should add to dislikers when -1" do 
      pending
    end

    it "should remove from like/dislikers when 0" do 
      pending
    end

  end

end
