require 'spec_helper'

describe Comment do
  before(:each) do 
    User.delete_all
    Item.delete_all
    @user = FactoryGirl.create(:user)
    @item = FactoryGirl.create(:item)
    @comment = FactoryGirl.build(:comment)
    @comment.item = @item
    @comment.author = @user
    @comment.save
  end

  #{{{ user_likes?
  describe "user likes" do 

    it "returns 1 if user likes" do 
      @comment.likers << @user
      @comment.user_likes?(@user).should == 1
    end

    it "returns -1 if user likes" do 
      @comment.dislikers << @user ; @comment.save ; @comment.reload
      @comment.user_likes?(@user).should == -1
    end

    it "returns nil else" do 
      @comment.user_likes?(@user).should == 0
    end

  end
  #}}}

end
