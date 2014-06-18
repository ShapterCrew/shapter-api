require 'spec_helper'

describe Shapter::V4::ConfirmStudents do 

  before(:each) do 
    User.delete_all
    @user = FactoryGirl.create(:user)
  end

  #{{{ /me
  describe :me do 

    context "when logged in" do 
      before do 
      end

      it "present current user" do
        login(@user)
        get "users/me"
        access_denied(@response).should be_false
        h = JSON.parse(@response.body)
        h["firstname"].should == @user.firstname
        h["lastname"].should == @user.lastname
      end
    end

    context "when NOT logged in" do 
      it "denies access" do 
        get "users/me"
        access_denied(@response).should be_true
      end
    end
  end

  #}}}

end
