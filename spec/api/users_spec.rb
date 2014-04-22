require 'spec_helper'

describe Shapter::Users do 

  before(:each) do 
    User.delete_all
    @user = FactoryGirl.create(:user)
  end

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

end
