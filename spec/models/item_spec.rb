require 'spec_helper'

describe Item do
  before(:each) do 
    User.delete_all
    Item.delete_all
    @user = FactoryGirl.create(:user)
    @item = FactoryGirl.create(:item)
  end

  #{{{ avg_scores
  describe :avg_scores do 
    before do 
      @c1 = FactoryGirl.build(:comment) ; @c1.work_score = 1 ; @c1.quality_score = 3
      @c2 = FactoryGirl.build(:comment) ; @c2.work_score = 2 ; @c2.quality_score = 4
      @item.comments << @c1
      @item.comments << @c2
    end
    it "avg_quality_score averages quality score" do 
      @item.avg_quality_score.should == 3.5
    end
    it "avg_work_score averages work score" do 
      @item.avg_work_score.should == 1.5
    end
  end
  #}}}

  #{{{ current_user_subscribed?
  describe :current_user_subscribed? do

    it "returns false if user didn't subscribed" do 
      @item.user_subscribed?(@user).should be_false
    end

    it "returns true if user subscribed" do 
      @item.subscribers << @user ; @item.save ; @item.reload
      @item.user_subscribed?(@user).should be_true
    end
  end
  #}}}

  #{{{ current_user_has_in_cart?
  describe :current_user_has_in_cart? do

    it "returns false if user don't have in cart" do 
      @item.user_has_in_cart?(@user).should be_false
    end

    it "returns true if user has in cart" do 
      @item.interested_users << @user ; @item.save ; @item.reload
      @item.user_has_in_cart?(@user).should be_true
    end
  end
  #}}}

  #{{{ user_comments_count
  describe "user_comments_count" do
    it "returns the number of comments the user wrote" do 
      @item.user_comments_count(@user).should == 0
      c = FactoryGirl.build(:comment)
      c.author = @user
      @item.comments << c ; @item.save ; @item.reload
      @item.user_comments_count(@user).should == 1
    end
  end
  #}}}

  #{{{ Item.touch
  describe "self.touch" do 
    it "should update" do 
      t = Time.now
      Item.max(:updated_at).should < t
      Item.touch
      Item.max(:updated_at).should > t
    end
  end
  #}}}

end
