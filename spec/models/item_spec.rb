require 'spec_helper'

describe Item do
  before(:each) do 
    User.delete_all
    Item.delete_all
    @user = FactoryGirl.create(:user)
    @item = FactoryGirl.create(:item)
  end

  #{{{ user_likes?
  describe "user likes" do 

    it "returns 1 if user likes" do 
      @item.likers << @user
      @item.user_likes?(@user).should == 1
    end

    it "returns -1 if user likes" do 
      @item.dislikers << @user ; @item.save ; @item.reload
      @item.user_likes?(@user).should == -1
    end

    it "returns nil else" do 
      @item.user_likes?(@user).should == 0
    end

  end
  #}}}

end
