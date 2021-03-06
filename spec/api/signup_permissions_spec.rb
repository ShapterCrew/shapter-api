require 'spec_helper'
describe Shapter::V7::SignupPermissions do 
  before(:each) do 
    User.delete_all
    Tag.delete_all
    SignupPermission.delete_all

    @tag =  FactoryGirl.create(:tag)
    @user = FactoryGirl.create(:user)

    @params = {
      :email => "UserToInvite@someschool.com",
      :school_tag_ids => [@tag.id.to_s],
      :firstname => "myFirstName",
      :lastname => "myLastName",
    }

  end

  describe "signup-permission" do 

    #{{{ create
    context "when not admin" do 

      it "should deny access when not logged in" do 
        put "signup-permissions", :signup_permission => @params
        expect(access_denied(@response)).to eq true
      end

      it "should deny access for non admin user" do 
        User.any_instance.stub(:shapter_admin).and_return(false)
        login(@user)
        put "signup-permissions", :signup_permission => @params
        expect(access_denied(@response)).to eq true
      end
    end
    context "when admin" do 
      before do 
        User.any_instance.stub(:shapter_admin).and_return(true)
        login(@user)
      end
      it "should create a permission" do 
        SignupPermission.count.should == 0
        put "signup-permissions", :signup_permission => @params, entities: {signup_permission: {email: true, firstname: true, lastname: true}}
        access_denied(@response).should be false
        SignupPermission.count.should == 1
        JSON.parse(@response.body)["id"].should == SignupPermission.last.id.to_s
        JSON.parse(@response.body)["email"].should == SignupPermission.last.email
        JSON.parse(@response.body)["firstname"].should == SignupPermission.last.firstname
        JSON.parse(@response.body)["lastname"].should == SignupPermission.last.lastname
      end
    end
    #}}}

    #{{{ destroy
    describe :destroy do 
      before do 
        @signup_perm = FactoryGirl.create(:signup_permission)
      end
      context "when not admin" do 

        it "should deny access when not logged in" do 
          delete "signup-permissions/#{@signup_perm.id}"
          expect(access_denied(@response)).to eq true
        end

        it "should deny access for non admin user" do 
          User.any_instance.stub(:shapter_admin).and_return(false)
          login(@user)
          delete "signup-permissions/#{@signup_perm.id}"
          expect(access_denied(@response)).to eq true
        end
      end
      context "when admin" do 
        before do 
          User.any_instance.stub(:shapter_admin).and_return(true)
          login(@user)
        end
        it "should destroy a permission" do 
          SignupPermission.count.should == 1
          delete "signup-permissions/#{@signup_perm.id}"
          access_denied(@response).should be false
          SignupPermission.count.should == 0
        end
      end
    end
    #}}}

  end

end
