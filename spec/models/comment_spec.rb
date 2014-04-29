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

    it "returns 0 else" do 
      @comment.user_likes?(@user).should == 0
    end

  end
  #}}}

  #{{{ dislikers_count
  describe "dislikers_count" do 
    it 'returns the number of dislikers' do 
      @comment.dislikers_count.should == 0
      @comment.dislikers << @user
      @comment.dislikers_count.should == 1
    end
  end
  #}}}

  #{{{ likers_count
  describe "likers_count" do 
    it 'returns the number of likers' do 
      @comment.likers_count.should == 0
      @comment.likers << @user
      @comment.likers_count.should == 1
    end
  end
  #}}}

end
