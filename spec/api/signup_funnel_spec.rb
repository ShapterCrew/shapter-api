require 'spec_helper'

describe Shapter::V7::SignupFunnel do 
  before(:each) do 
    Tag.delete_all
    User.delete_all

    @tag = FactoryGirl.create(:tag)

    @signup_params = [
      {"name" => "foo", "tag_ids" => [@tag.id.to_s]},
      {"name" => "bar", "tag_ids" => [@tag.id.to_s]},
    ]

    @user = FactoryGirl.create(:user)
    @user.schools = [@tag]
    @user.save
    login(@user)
  end

  describe "admin routes" do 

    #{{{ put
    describe "put" do 
      context "when not admin" do 
        before do 
          User.any_instance.stub(:shapter_admin).and_return(false)
          put "tags/#{@tag.id}/signup-funnel", :signup_funnel => @signup_params
        end

        it "denies access" do 
          access_denied(@response).should be true
        end
      end
      context "when admin" do 
        before do 
          User.any_instance.stub(:shapter_admin).and_return(true)
          put "tags/#{@tag.id}/signup-funnel", :signup_funnel => @signup_params
        end

        it "allows access" do 
          access_denied(@response).should be false
        end

        it "set proper values" do 
          @tag.reload
          @tag.signup_funnel.should == @signup_params
        end

        it "returns signup_funnel" do 
          a = JSON.parse(@response.body)
          a.is_a?(Array).should be true
        end
      end
    end
    #}}}

    #{{{ get 
    describe "get" do 
      before do 
        @tag.signup_funnel = @signup_params
        @tag.save
        @tag.reload
      end
      context "when not admin" do 
        before do 
          User.any_instance.stub(:shapter_admin).and_return(false)
          post "tags/#{@tag.id}/signup-funnel"
        end

        it "denies access" do
          access_denied(@response).should be true
        end
      end
      context "when admin" do 
        before do 
          User.any_instance.stub(:shapter_admin).and_return(true)
          post "tags/#{@tag.id}/signup-funnel"
        end

        it "allows access" do 
          access_denied(@response).should be false
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
        @tag.signup_funnel = @signup_params
        @tag.save
        @tag.reload
      end
      context "when not admin" do 
        before do 
          User.any_instance.stub(:shapter_admin).and_return(false)
          delete "tags/#{@tag.id}/signup-funnel"
        end

        it "denies access" do 
          access_denied(@response).should be true
        end
      end
      context "when admin" do 
        before do 
          User.any_instance.stub(:shapter_admin).and_return(true)
          delete "tags/#{@tag.id}/signup-funnel"
        end

        it "deletes the funnel" do 
          @tag.reload
          @tag.signup_funnel.should be_nil
          JSON.parse(@response.body).should == {"status" => "deleted"}
        end
      end
    end
    #}}}

  end

  describe "users routes" do 

    #{{{ get item list
    describe "get" do 
      before do 
        @tag.signup_funnel = @signup_params
        @item = FactoryGirl.create(:item)
        @item.tags << @tag
        @item.save ; @item.reload
        @tag.save ; @tag.reload
        @user.schools = [@tag]
      end

      it "should fucking work" do 
        post "users/me/signup-funnel/1", :school_id => @user.schools.first.id.to_s
        a = JSON.parse(@response.body)

        a["total_nb_of_steps"].should == 2
        a["name"].should == "foo"
        a["items"].size.should == 1
        a["items"].first["id"].should == @item.id.to_s


        post "users/me/signup-funnel/2", :school_id => @user.schools.first.id.to_s
        a = JSON.parse(@response.body)
        a["name"].should == "bar"

        post "users/me/signup-funnel/20", :school_id => @user.schools.first.id.to_s
        a = JSON.parse(@response.body)
        #should error, but not raise any exception
      end

    end
    #}}}

  end

end
