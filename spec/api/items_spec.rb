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

  def access_denied(resp)
    resp.status == 401 and resp.body = {error: "denied"}.to_json
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
        get "items/#{@item.id}", filter: @filter
        access_denied(response).should be_true
      end
    end

    context "when logged in" do 
    end
  end
  #}}}

  #{{{ subscribe
  describe :subscribe do 
    context "when logged off" do 
      it "should deny access" do 
        put "items/#{@item.id}/subscribe", filter: @filter
        access_denied(response).should be_true
      end
    end

    context "when logged in" do 
    end
  end
  #}}}

  #{{{ unsubscribe
  describe :unsubscribe do 
    context "when logged off" do 
      it "should deny access" do 
        put "items/#{@item.id}/unsubscribe", filter: @filter
        access_denied(response).should be_true
      end
    end

    context "when logged in" do 
    end
  end
  #}}}

end
