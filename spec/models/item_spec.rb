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

end
