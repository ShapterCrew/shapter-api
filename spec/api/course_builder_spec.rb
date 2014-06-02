require 'spec_helper'

describe Shapter::V4::CourseBuilder do 

  before(:each) do 
    Tag.delete_all
    Item.delete_all
    User.delete_all

    @user = FactoryGirl.create(:user)
    @tag = FactoryGirl.create(:tag)
    @item = FactoryGirl.create(:item)

    login(@user)
  end

  #{{{ course builder
  describe "course builder" do 

    before do 
        @tag.signup_funnel_tag_list = [{name: "haha, recursion!", tag_ids: [@tag.id]}]
        @tag.save
    end

    context "when user doesn't belong to asked school" do 
      it "denies access" do 
        get "/users/me/courses/builder", :schoolTagId => @tag.id.to_s
        access_denied(@response).should be_true
      end
    end
    context "when user belongs to asked school" do 
      it "success" do 
        @user.schools << @tag
        get "/users/me/courses/builder", :schoolTagId => @tag.id.to_s
        access_denied(@response).should be_false
        @response.status.should == 200
      end
    end

    end
  #}}} 

end