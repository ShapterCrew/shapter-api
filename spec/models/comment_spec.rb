require 'spec_helper'

describe Comment do
  before(:each) do 
    User.delete_all
    Item.delete_all
    Tag.delete_all

    @t = FactoryGirl.create(:tag)

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

    it "shows content when alien is publishing in my campus" do 
      @t = FactoryGirl.create(:tag)
      @user.stub(:schools).and_return([@t])
      @user2.stub(:schools).and_return([])
      expect(@comment.public_content(@user2)).to eq @comment.content
    end

    it "hide content otherwise" do 
      #has to remove school from user2 ( there is a school from factoryGirl)
      @user2.stub(:schools).and_return([])
      @user2.stub(:school_ids).and_return([])
      expect(@comment.public_content(@user2)).to eq "hidden"
    end

  end
  #}}}

  #{{{ alien comments
  describe :alien? do 

    it "is alien when user comments in a school he doesn't belong to" do 
      @item.update_attribute(:tag_ids, [@t.id])
      @user.update_attribute(:school_ids, [])

      expect( @comment.alien?).to be true
    end

    it "is NOT alien when user comments in a school he belongs to" do 

      @item.update_attribute(:tag_ids, [@t.id])
      @user.update_attribute(:school_ids, [@t.id])

      expect( @comment.alien?).to be false
    end

  end
  #}}}

  describe :context do 

    it "NON-alien comment doesn't requires context" do
      @comment.stub(:alien?).and_return(false)
      @comment.stub(:context).and_return(nil)

      expect(@comment.valid?).to be true
    end

    it "alien comment requires context" do 
      @comment.stub(:alien?).and_return(true)
      @comment.stub(:context).and_return(nil)

      expect(@comment.valid?).to be false
    end

    it "context should not be more than 70 characters" do
      expect(@comment.valid?).to be true
      @comment.stub(:context).and_return((0..99).map{|_| "x"}.join)
      expect(@comment.valid?).to be false
    end


  end

end
