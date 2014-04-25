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
    @t2 = Tag.new(name: :t2) ; @t2.save
    @t3 = Tag.new(name: :t3) ; @t3.save

    @item.tags << @t1 ; @item.tags << @t2
    @item2.tags << @t1; @item2.tags << @t3
    @item.save
    @item2.save
    @filter = ["t1","t2"]

    @item.reload
    @item2.reload
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
        a.map{|h| h["id"]}.should =~ [@item.id, @item2.id].map(&:to_s)

        get "items/filter", filter: ["t1","t3"]
        a = JSON.parse(response.body)
        a.map{|h| h["id"]}.should =~ [@item2.id].map(&:to_s)

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
        i["id"].should == @item.id.to_s
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

  #{{{ delete
  describe :delete do 
    context "when not admin" do 
      before do 
        login(@user)
      end
      it "denies access" do 
        delete "items/#{@item.id}"
        access_denied(@response).should be_true
      end
    end
    context "when admin" do 
      before do 
        login(@user)
        User.any_instance.stub(:shapter_admin).and_return(true)
      end
      it "destroy an item" do 
        tags = @item.tags
        tags.select{|t| t.item_ids.include?(@item.id)}.empty?.should be_false
        delete "items/#{@item.id}"

        Item.find(@item.id).should be_nil
        tags.select{|t| t.reload ; t.item_ids.include?(@item.id)}.empty?.should be_true

      end
    end
  end
  #}}}

  #{{{ update
  describe :update do 
    context "when not admin" do 
      before do 
        login(@user)
        User.any_instance.stub(:shapter_admin).and_return(false)
      end
      it "denies access" do 
        put "items/#{@item.id}/update", :item => {:name => "new name ", :description => "soooo cool!"}
        access_denied(@response).should be_true
      end
    end
    context "when admin" do 
      before do 
        login(@user)
        User.any_instance.stub(:shapter_admin).and_return(true)
      end
      it "destroy an item" do 
        new_name = "new name"
        desc = "soooooo cool !"
        put "items/#{@item.id}/update", :item => {:name => new_name, :description => desc}

        @item.reload
        @item.name.should == new_name
        @item.description.should == desc

      end
    end
  end
  #}}}

  describe :tags do 

    # {{{ add_tag
    describe :add do 
      context "when not logged" do 
        it "denies access" do 
          put "items/#{@item.id}/tags/newtag"
          access_denied(response).should be_true
        end
      end

      context "when not admin" do 
        it "denies access" do 
          login(@user)
          put "items/#{@item.id}/tags/newtag"
          access_denied(response).should be_true
        end
      end

      context "when admin" do
        it "allows access" do 
          login(@user)
          User.any_instance.stub(:shapter_admin).and_return(true)
          put "items/#{@item.id}/tags/newtag"
          access_denied(response).should be_false
        end

        it "adds tag" do 
          login(@user)
          User.any_instance.stub(:shapter_admin).and_return(true)
          put "items/#{@item.id}/tags/newtag"
          @item.reload
          @item.tags.last.name.should == "newtag"
          Tag.last.name.should == "newtag"
        end
      end
    end
    # }}}

    #{{{ delete
    describe :delete do 

      context "when logged of" do 
        it "denies access" do 
          delete "/items/#{@item.id}/tags/#{@t1.name}"
          access_denied(@response).should be_true
        end
      end

      context "when logged in as user" do 
        before do 
          login(@user)
        end
        it "denies access" do 
          delete "/items/#{@item.id}/tags/#{@t1.name}"
          access_denied(@response).should be_true
        end
      end

      context 'when logged in as admin' do 
        before do 
          login(@user)
          User.any_instance.stub(:shapter_admin).and_return(true)
          @item.tags << @t1 ; @item.save
          @item.tags << @t2 ; @item.save
        end

        it "allows access" do 
          delete "/items/#{@item.id}/tags/#{@t1.name}"
          access_denied(@response).should be_false
        end

        it "deletes the tag from item tags list" do
          @item.tags.include?(@t1).should be_true
          delete "/items/#{@item.id}/tags/#{@t1.name}"
          @item.reload
          @item.tags.include?(@t1).should be_false
        end

        it "delete the item from the tag items list" do 
          @t1.items.include?(@item).should be_true
          delete "/items/#{@item.id}/tags/#{@t1.name}"
          @t1.reload
          @t1.items.include?(@item).should be_false
        end

        it "removes the tag from base if no item correspond to this tag anymore" do 
          @t2.items.include?(@item).should be_true
          Tag.where(name: @t2.name).empty?.should be_false
          @t2.items.size.should == 1
          delete "/items/#{@item.id}/tags/#{@t2.name}"
          Tag.where(name: @t2.name).empty?.should be_true
        end

      end

    end
    #}}}

  end

  describe :comments do 

    #{{{ index
    describe :index do

      context "when logged of" do
        it "denies access" do 
          get "items/#{@item.id}/comments"
          access_denied(@response).should be_true
        end
      end

      context "when logged in as student" do 
        before do 
          login(@user)
        end

        it "allows access if item belongs to current_user.school " do 
          @user.school = @item.tags.last ; @user.save ; @user.reload

          get "items/#{@item.id}/comments"
          access_denied(@response).should be_false
        end

        it "denies access if item does NOT belong to current_user.school " do 
          get "items/#{@item.id}/comments"
          access_denied(@response).should be_true
        end
      end

      context "when logged in as admin" do 
        before do 
          login(@user)
          User.any_instance.stub(:shapter_admin).and_return(true)
        end

        it "allows access if item does NOT belong to current_user.school " do 
          get "items/#{@item.id}/comments"
          access_denied(@response).should be_false
        end

        it "list items comments" do 
          c = FactoryGirl.build(:comment) ;  c.author = @user
          @item.comments << c
          @item.save ; @item.reload
          get "items/#{@item.id}/comments"
          a = JSON.parse(response.body)
          a.is_a?(Array).should be_true
          a.size.should == @item.comments.size
          a.last["id"].should == @item.comments.last.id.to_s
        end

      end
    end
    #}}}

  end

end
