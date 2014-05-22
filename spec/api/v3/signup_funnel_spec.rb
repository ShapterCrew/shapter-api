require 'spec_helper'

describe Shapter::V3::SignupFunnel do 
  before(:each) do 
    Tag.delete_all
    User.delete_all

    @user = FactoryGirl.create(:user)
    login(@user)

    @tag = FactoryGirl.create(:tag)

    @signup_params = [
      {"name" => "foo", "tag_ids" => [@tag.id.to_s]},
      {"name" => "bar", "tag_ids" => [@tag.id.to_s]},
    ]
  end

  #{{{ put
  describe "put" do 
    context "when not admin" do 
      before do 
        User.any_instance.stub(:shapter_admin).and_return(false)
        put "tags/#{@tag.id}/signup-funnel", :signup_funnel => @signup_params
      end

      it "denies access" do 
        access_denied(@response).should be_true
      end
    end
    context "when admin" do 
      before do 
        User.any_instance.stub(:shapter_admin).and_return(true)
        put "tags/#{@tag.id}/signup-funnel", :signup_funnel => @signup_params
      end

      it "allows access" do 
        access_denied(@response).should be_false
      end

      it "set proper values" do 
        @tag.reload
        @tag.signup_funnel_tag_list.should == @signup_params
      end

      it "returns signup_funnel" do 
        a = JSON.parse(@response.body)
        a.is_a?(Array).should be_true
      end
    end
  end
  #}}}

  #{{{ get 
  describe "get" do 
    before do 
      @tag.signup_funnel_tag_list = @signup_params
      @tag.save
      @tag.reload
    end
    context "when not admin" do 
      before do 
        User.any_instance.stub(:shapter_admin).and_return(false)
        get "tags/#{@tag.id}/signup-funnel"
      end

      it "denies access" do
        access_denied(@response).should be_true
      end
    end
    context "when admin" do 
      before do 
        User.any_instance.stub(:shapter_admin).and_return(true)
        get "tags/#{@tag.id}/signup-funnel"
      end

      it "allows access" do 
        access_denied(@response).should be_false
      end

      it "finds and return values" do 
        JSON.parse(@response.body).should == {"signup_funnel" => @signup_params}
      end
    end
  end
  #}}}

  #{{{ delete
  describe "delete" do 
    before do
      @tag.signup_funnel_tag_list = @signup_params
      @tag.save
      @tag.reload
    end
    context "when not admin" do 
      before do 
        User.any_instance.stub(:shapter_admin).and_return(false)
        delete "tags/#{@tag.id}/signup-funnel"
      end

      it "denies access" do 
        access_denied(@response).should be_true
      end
    end
    context "when admin" do 
      before do 
        User.any_instance.stub(:shapter_admin).and_return(true)
        delete "tags/#{@tag.id}/signup-funnel"
      end

      it "deletes the funnel" do 
        @tag.reload
        @tag.signup_funnel_tag_list.should be_nil
        JSON.parse(@response.body).should == {"status" => "deleted"}
      end
    end
  end
  #}}}

end
