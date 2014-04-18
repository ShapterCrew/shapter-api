require 'spec_helper'

describe Shapter::Items do 

  before(:each) do 
    Item.delete_all
    User.delete_all
    Tag.delete_all
    @user = FactoryGirl.create(:user)
    @item = FactoryGirl.create(:item)
    @item2= FactoryGirl.create(:item)

    @t1 = Tag.new(name: :t1) ; @t1.save
    @t2 = Tag.new(name: :t2) ; @t1.save
    @t3 = Tag.new(name: :t3) ; @t1.save

    @item.tags = [@t1,@t2]
    @item2.tags = [@t1,@t3]
    @item.save
    @item2.save
    @filter = ["t1","t2"]
  end


  # {{{ filter
  describe :filter do 
    context "when logged off" do 
      it "should deny access" do 
        get "items/filter", filter: @filter
        access_denied(response).should be_true
      end
    end

    context "when logged in" do 
      before do 
        login(@user)
      end
      it "should filter properly" do 
        get "items/filter", filter: ["t1"]
        a = JSON.parse(response.body)
        a.map{|h| h["$oid"]}.should =~ [@item.id, @item2.id].map(&:to_s)

        get "items/filter", filter: ["t1","t3"]
        a = JSON.parse(response.body)
        a.map{|h| h["$oid"]}.should =~ [@item2.id].map(&:to_s)

        get "items/filter", filter: ["t1","hahahalol"]
        a = JSON.parse(response.body)
        a.empty?.should be_true
      end
    end
  end
  #}}}

  #{{{ get
  describe :get do 
    context "when logged off" do 
      it "should deny access" do 
        get "items/#{@item.id}"
        access_denied(response).should be_true
      end
    end

    context "when logged in" do 
      before do 
        login(@user)
      end

      it "should error if iten is not found" do 
        get "items/hahahanononon"
        response.body.should == {error: "not found"}.to_json
        response.status.should == 404
      end

      it "should returns item when found" do 
        get "items/#{@item.id}"
        response.status.should == 200
        i = JSON.parse(response.body)
        i["_id"]["$oid"].should == @item.id.to_s
      end

    end
  end
  #}}}

  #{{{ subscribe
  describe :subscribe do 
    context "when logged off" do 
      it "should deny access" do 
        put "items/#{@item.id}/subscribe"
        access_denied(response).should be_true
      end
    end

    context "when logged in" do 
      before do 
        login(@user)
      end
      it "should add to subscribers list" do 
        put "items/#{@item.id}/subscribe"
        response.body.should == {:id => @item.id, :status => :subscribed }.to_json

        @item.reload
        @user.reload
        @user.items.include?(@item).should be_true
        @item.subscribers.include?(@user).should be_true
      end
    end
  end
  #}}}

  #{{{ unsubscribe
  describe :unsubscribe do 
    context "when logged off" do 
      it "should deny access" do 
        put "items/#{@item.id}/unsubscribe"
        access_denied(response).should be_true
      end
    end

    context "when logged in" do 
      before do 
        login(@user)
        @item.subscribers << @user
        @item.save
        @item.reload
      end

      it "should unsubscribe" do 
        @item.subscribers.include?(@user).should be_true
        @user.items.include?(@item).should be_true
        put "items/#{@item.id}/unsubscribe"
        access_denied(response).should be_false
        @item.reload
        @user.reload
        @item.subscribers.include?(@user).should be_false
        @user.items.include?(@item).should be_false

        response.body.should == {:id => @item.id, :status => :unsubscribed}.to_json

      end
    end
  end
  #}}}

  # {{{ add_tag
  describe :add_tag do 
    context "when not logged" do 
      it "denies access" do 
        post "items/#{@item.id}/add_tag", :tag_name => "newtag"
        access_denied(response).should be_true
      end
    end

    context "when not admin" do 
      it "denies access" do 
        login(@user)
        post "items/#{@item.id}/add_tag", :tag_name => "newtag"
        access_denied(response).should be_true
      end
    end

    context "when admin" do
      it "allows access" do 
        login(@user)
        User.any_instance.stub(:shapter_admin).and_return(true)
        post "items/#{@item.id}/add_tag", :tag_name => "newtag"
        access_denied(response).should be_false
      end

      it "adds tag" do 
        login(@user)
        User.any_instance.stub(:shapter_admin).and_return(true)
        post "items/#{@item.id}/add_tag", :tag_name => "newtag"
        @item.reload
        @item.tags.last.name.should == "newtag"
        Tag.last.name.should == "newtag"
      end
    end
  end
  # }}}

end
