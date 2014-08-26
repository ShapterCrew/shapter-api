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
    @comment.reload
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
      @comment.dislikers << @user
      @comment.dislikers_count.should == 1
    end
  end
  #}}}

  #{{{ likers_count
  describe "likers_count" do 
    it 'returns the number of likers' do 
      @comment.likers << @user ; puts @comment.save  ; @comment.reload
      @comment.likers_count.should == 1
    end
  end
  #}}}

  #{{{ public_content
  describe :public_content do 
    before do 
      @user2 = FactoryGirl.build(:user)
      @user2.email = 'email2@hahahoho.com'
    end

    it "shows content if asking user if fb friend" do 
      @user2.stub(:friends).and_return(@user)
      expect(@comment.public_content(@user2)).to eq @comment.content
    end

    it "shows content if asking user share a school with author" do 
      @t = FactoryGirl.create(:tag)
      @user.stub(:schools).and_return([@t])
      @user2.stub(:schools).and_return([@t])
      expect(@comment.public_content(@user2)).to eq @comment.content
    end

    it "shows content if forced to " do 
      expect(@comment.public_content(@user2,true)).to eq @comment.content
    end

    it "hide content otherwise" do 
      #has to remove school from user2 ( there is a school from factoryGirl)
      @user2.stub(:schools).and_return([])
      @user2.stub(:school_ids).and_return([])
      expect(@comment.public_content(@user2)).to eq "hidden"
    end

  end
  #}}}

end
