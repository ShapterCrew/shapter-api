require 'spec_helper'

describe Shapter::V4::Users do 

  before(:each) do 
    User.delete_all
    Item.delete_all
    @user = FactoryGirl.create(:user)

    @user2 = FactoryGirl.build(:user)
    @user2.email = "another_email@haha.com"
    @user2.save
    @user2.reload
  end

  #{{{ /me
  describe :me do 

    context "when logged in" do 
      before do 
        login(@user)
      end

      it "present current user" do
        get "users/me"
        access_denied(response).should be_false
        h = JSON.parse(response.body)
        h["email"].should == @user.email
      end
    end

    context "when NOT logged in" do 
      it "denies access" do 
        get "users/me"
        access_denied(response).should be_true
      end
    end
  end

  #}}}

  #{{{ comment_pipe
  describe "comment-pipe" do

    before do
      login(@user)
      @i1 = FactoryGirl.create(:item)
      @i2 = FactoryGirl.create(:item)
      @i3 = FactoryGirl.create(:item)
      @i4 = FactoryGirl.create(:item)
      is = [@i1,@i2,@i3,@i4]

      @user.items << @i1
      @user.items << @i2
      @user.items << @i3

      @i2.stub(:interested_users_count).and_return(1)
      @i3.stub(:subscribers_count).and_return(2)

      [@i1,@i2,@i3].each(&:save)
    end

    it "should get 1 item to comment" do 
      get "/users/me/comment-pipe", n: 1
      h = JSON.parse(@response.body)
      h.size.should == 1
    end

    it "should get 3 items in proper order" do 
      get "/users/me/comment-pipe", n: 3
      h = JSON.parse(@response.body)
      h["commentable_items"].size.should == 3
      h["commentable_items"].sort_by{|h| h["requires_comment_score"]}.reverse.map{|h| h["id"]}.should == [@i2,@i1,@i3].map(&:id).map(&:to_s)
    end

  end
  #}}}

end
