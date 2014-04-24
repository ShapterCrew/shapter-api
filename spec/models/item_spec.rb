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

end
