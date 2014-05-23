require 'spec_helper'

describe Shapter::V3::Items do 

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

  #{{{ create_with_tags
  describe :create_with_tags do
    before do 
      login(@user)
    end
    context "when non admin user" do 
      before do 
        User.any_instance.stub(:shapter_admin).and_return(false)
      end

      it "denies access" do 
        post "items/create_with_tags", {:itemNames => ["fooitem","baritem"], :tagNames => ["footag","bartag"]}
        access_denied(@response).should be_true
      end
    end

    context "when admin" do 
      before do 
        User.any_instance.stub(:shapter_admin).and_return(true)
        post "items/create_with_tags", {:itemNames => ["fooitem","baritem"], :tagNames => ["footag","bartag"]}
      end

      it "allows access" do 
        access_denied(@response).should be_false
      end

      it 'creates properly named item' do 
        Item.where(name: "fooitem").exists?.should be_true
        Item.where(name: "baritem").exists?.should be_true
      end

      it 'creates item with proper tags' do 
        Item.find_by(name: "fooitem").tags.map(&:name).should =~ ["footag","bartag","fooitem"]
        Item.find_by(name: "baritem").tags.map(&:name).should =~ ["footag","bartag","baritem"]
      end

      it 'given tags are properly created/updated' do 
        Tag.where(name: "footag").exists?.should be_true
        i1 = Item.find_by(name: "fooitem")
        i2 = Item.find_by(name: "baritem")
        Tag.find_by(name: "footag").items.map(&:id).map(&:to_s).should =~ [i1,i2].map(&:id).map(&:to_s)
      end
    end
  end
  #}}}

  # {{{ filter
  describe :filter do 
    context "when logged off" do 
      it "should deny access" do 
        get "items/filter", {filter: @filter}, {"Accept-Version" => "v2"}
        access_denied(response).should be_true
      end
    end

    context "when logged in" do 
      before do 
        login(@user)
      end
      it "should filter properly" do 
        get "items/filter", {filter: [@t1.id.to_s]}, {"Accept-Version" => "v2"}
        a = JSON.parse(response.body)
        a.map{|h| h["id"]}.should =~ [@item.id, @item2.id].map(&:to_s)

        get "items/filter", {filter: [@t1.id.to_s,@t3.id.to_s]}, {"Accept-Version" => "v2"}
        a = JSON.parse(response.body)
        a.map{|h| h["id"]}.should =~ [@item2.id].map(&:to_s)

        get "items/filter", {filter: [@t1.id.to_s,"hahahalol"]}, {"Accept-Version" => "v2"}
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
        post "items/#{@item.id}/subscribe"
        access_denied(response).should be_true
      end
    end

    context "when logged in" do 
      before do 
        login(@user)
      end
      it "should add to subscribers list" do 
        post "items/#{@item.id}/subscribe"
        JSON.parse(response.body)["id"].should == @item.id.to_s

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
        post "items/#{@item.id}/unsubscribe"
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
        post "items/#{@item.id}/unsubscribe"
        access_denied(response).should be_false
        @item.reload
        @user.reload
        @item.subscribers.include?(@user).should be_false
        @user.items.include?(@item).should be_false
      end
    end
  end
  #}}}

  #{{{ subscribe
  describe :cart do 
    context "when logged off" do 
      it "should deny access" do 
        post "items/#{@item.id}/cart"
        access_denied(response).should be_true
      end
    end

    context "when logged in" do 
      before do 
        login(@user)
      end
      it "should add to cart list" do 
        post "items/#{@item.id}/cart"
        JSON.parse(response.body)["id"].should == @item.id.to_s

        @item.reload
        @user.reload
        @user.cart_items.include?(@item).should be_true
        @item.interested_users.include?(@user).should be_true
      end
    end
  end
  #}}}

  #{{{ uncart
  describe :uncart do 
    context "when logged off" do 
      it "should deny access" do 
        post "items/#{@item.id}/uncart"
        access_denied(response).should be_true
      end
    end

    context "when logged in" do 
      before do 
        login(@user)
        @item.interested_users << @user
        @item.save
        @item.reload
      end

      it "should unsubscribe" do 
        @item.interested_users.include?(@user).should be_true
        @user.cart_items.include?(@item).should be_true
        post "items/#{@item.id}/uncart"
        access_denied(response).should be_false
        @item.reload
        @user.reload
        @item.interested_users.include?(@user).should be_false
        @user.cart_items.include?(@item).should be_false
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
          @item.tags.sort_by(&:updated_at).last.name.should == "newtag"
          Tag.all.sort_by(&:updated_at).last.name.should == "newtag"
        end
      end
    end
    # }}}

    #{{{ delete
    describe :delete do 

      context "when logged of" do 
        it "denies access" do 
          delete "/items/#{@item.id}/tags/#{@t1.id}"
          access_denied(@response).should be_true
        end
      end

      context "when logged in as user" do 
        before do 
          login(@user)
        end
        it "denies access" do 
          delete "/items/#{@item.id}/tags/#{@t1.id}"
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
          delete "/items/#{@item.id}/tags/#{@t1.id}"
          access_denied(@response).should be_false
        end

        it "deletes the tag from item tags list" do
          @item.tags.include?(@t1).should be_true
          delete "/items/#{@item.id}/tags/#{@t1.id}"
          @item.reload
          @item.tags.include?(@t1).should be_false
        end

        it "delete the item from the tag items list" do 
          @t1.items.include?(@item).should be_true
          delete "/items/#{@item.id}/tags/#{@t1.id}"
          @t1.reload
          @t1.items.include?(@item).should be_false
        end

        it "removes the tag from base if no item correspond to this tag anymore" do 
          @t2.items.include?(@item).should be_true
          Tag.where(name: @t2.name).empty?.should be_false
          @t2.items.size.should == 1
          delete "/items/#{@item.id}/tags/#{@t2.id}"
          Tag.where(name: @t2.name).empty?.should be_true
        end

        it "removing or destroying tag should not delete item" do 
          delete "/items/#{@item.id}/tags/#{@t2.id}"
          @item.reload
          Item.where(id: @item.id).exists?.should be_true

          @t1.destroy
          @item.reload
          Item.where(id: @item.id).exists?.should be_true
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
          @user.schools << @item.tags.last ; @user.save ; @user.reload

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
