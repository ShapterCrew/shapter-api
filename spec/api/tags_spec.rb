require 'spec_helper'

describe Shapter::Tags do 

  before(:each) do 
    Tag.delete_all
    User.delete_all
    Item.delete_all
    @item = FactoryGirl.create(:item)
    @user = FactoryGirl.create(:user)
    @tag = FactoryGirl.create(:tag)

    @item.tags << @tag
    @item.subscribers << @user
    @item.save

    @user.reload
    @item.reload
    @tag.reload
  end

  #{{{ index
  describe :index do 

    context "when logged of" do 
      it "denies access" do 
        get "tags"
        access_denied(response).should be_true
      end
    end

    context "when logged in" do 
      before do 
        login(@user)
      end
      it "allows access" do 
        get "tags"
        access_denied(response).should be_false
      end

      it "list all tags" do 
        get "tags"
        response.body.should == [@tag].map{|t| {name: t.name}}.to_json
      end

    end

  end
  #}}}

  #{{{ suggested
  describe :suggested do 

    context "when logged of" do 
      it "denies access" do 
        get 'tags/suggested'
        access_denied(response).should be_true
      end
    end

    context "when logged in" do 
      before do 
        login(@user)
      end

      it "allows access" do 
        post 'tags/suggested', :filter => []
        access_denied(response).should be_false
      end

      it "provides user's tags" do 
        post "tags/suggested", :ignore_user => false, :selected_tags => ['foo']
        h = JSON.parse(response.body)
        h.has_key?("user_tags").should be_true
        h["user_tags"].should =~ [{"name" => @tag.name}]
      end

      it "ignores users's tag when asked" do 
        post "tags/suggested", :ignore_user => true, :selected_tags => ['foo']
        h = JSON.parse(response.body)
        h["user_tags"].blank?.should be_true
      end

      it "provides recommended tags" do 
        post "tags/suggested", :selected_tags => ['foo']
        h = JSON.parse(response.body)
        puts "debug: h = #{h}"
        h.has_key?("recommended_tags").should be_true
      end

    end

  end
  #}}}

end
