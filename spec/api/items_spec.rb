require 'spec_helper'

describe Shapter::V7::Items do 

  before(:each) do 
    User.any_instance.stub(:confirmed_student?).and_return(true)
    Item.delete_all
    User.delete_all
    Tag.delete_all
    Category.delete_all
    @user = FactoryGirl.create(:user)
    @item = FactoryGirl.create(:item)
    @item2= FactoryGirl.create(:item)
    @cat = FactoryGirl.create(:category)

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
      @h = {
        item_names: [
          "fooitem",
          "baritem",
        ],
        tags: [
          {category_id: @cat.id, tag_name: "footag"},
          {category_id: @cat.id, tag_name: "bartag"},
        ]
      }
    end
    context "when non admin user" do 
      before do 
        User.any_instance.stub(:shapter_admin).and_return(false)
      end

      it "denies access" do 
        post "items/create_with_tags", @h
        access_denied(@response).should be true
      end
    end

    context "when admin" do 
      before do 
        User.any_instance.stub(:shapter_admin).and_return(true)

        post "items/create_with_tags", @h

      end

      it "allows access" do 
        expect(access_denied(@response)).to be false
      end

      it 'creates properly named item' do 
        Item.where(name: "fooitem").exists?.should be true
        Item.where(name: "baritem").exists?.should be true

        h = JSON.parse(response.body)
        expect(h.has_key?("status")).to be true
        expect(h["status"]).to eq "created"
      end

      it 'creates item with proper tags' do 
        Item.find_by(name: "fooitem").tags.map(&:name).should =~ ["footag","bartag","fooitem"]
        Item.find_by(name: "baritem").tags.map(&:name).should =~ ["footag","bartag","baritem"]
      end

      it 'given tags are properly created/updated' do 
        Tag.where(name: "footag").exists?.should be true
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
        post "items/filter", {filter: @filter}
        access_denied(response).should be true
      end
    end

    context "when logged in" do 
      before do 
        login(@user)
      end
      it "should filter properly" do 
        post "items/filter", {filter: [@t1.id.to_s]}
        a = JSON.parse(response.body)
        a["items"].map{|h| h["id"]}.should =~ [@item.id, @item2.id].map(&:to_s)

        post "items/filter", {filter: [@t1.id.to_s,@t3.id.to_s]}
        a = JSON.parse(response.body)
        a["items"].map{|h| h["id"]}.should =~ [@item2.id].map(&:to_s)

        post "items/filter", {filter: [@t1.id.to_s,"hahahalol"]}
        a = JSON.parse(response.body)
        a["items"].blank?.should be true
      end

      it "should filter properly when :quality_filter option is passed" do 
        post "items/filter", {filter: [@t1.id.to_s], quality_filter: true}
        a = JSON.parse(response.body)
        a["items"].map{|h| h["id"]}.should =~ [@item.id, @item2.id].map(&:to_s)

        post "items/filter", {filter: [@t1.id.to_s,@t3.id.to_s], quality_filter: true}
        a = JSON.parse(response.body)
        a["items"].map{|h| h["id"]}.should =~ [@item2.id].map(&:to_s)

        post "items/filter", {filter: [@t1.id.to_s,"hahahalol"], quality_filter: true}
        a = JSON.parse(response.body)
        a["items"].blank?.should be true
      end

      it "should filter properly when :cart_only option is passed" do 
        @user.cart_items << @item2
        post "items/filter", {filter: [@t1.id.to_s], :cart_only => true}
        a = JSON.parse(response.body)
        a["items"].map{|h| h["id"]}.should =~ [@item2.id].map(&:to_s)
      end
    end
  end
  #}}}

  #{{{ get
  describe :get do 
    context "when logged off" do 
      it "should deny access" do 
        post "items/#{@item.id}"
        access_denied(response).should be true
      end
    end

    context "when logged in" do 
      before do 
        login(@user)
      end

      it "should error if iten is not found" do 
        post "items/hahahanononon"
        response.body.should == {error: "item not found"}.to_json
        response.status.should == 404
      end

      it "should returns item when found" do 
        post "items/#{@item.id}"
        response.status.should == 201
        i = JSON.parse(response.body)
        i["id"].should == @item.id.to_s
      end

      it "option current_user_has_diagram? should be true when user has diagram" do 
        @diag = FactoryGirl.build(:diagram)
        @diag.update_attributes(author: @user, item:@item)
        expect(@diag.valid?).to be true
        @diag.save

        post "items/#{@item.id}", :entities => {:item => {:current_user_has_diagram => true} }
        response.status.should == 201
        i = JSON.parse(response.body)
        expect(i.has_key?("current_user_has_diagram")).to be true
        expect(i["current_user_has_diagram"]).to be true
      end

      it "option current_user_has_diagram? should be false when user does NOT have a diagram" do 
        post "items/#{@item.id}", :entities => {:item => {:current_user_has_diagram => true} }
        response.status.should == 201
        i = JSON.parse(response.body)
        expect(i.has_key?("current_user_has_diagram")).to be true
        expect(i["current_user_has_diagram"]).to be false
      end

    end
  end
  #}}}

  #{{{ subscribe
  describe :subscribe do 
    context "when logged off" do 
      it "should deny access" do 
        post "items/#{@item.id}/subscribe"
        access_denied(response).should be true
      end
    end

    context "when logged in" do 
      before do 
        login(@user)
      end
      it "should add to subscribers list" do 
        User.any_instance.stub(:schools).and_return(@item.tags)
        post "items/#{@item.id}/subscribe"
        JSON.parse(response.body)["id"].should == @item.id.to_s

        @item.reload
        @user.reload
        @user.items.include?(@item).should be true
        @item.subscribers.include?(@user).should be true
      end
    end
  end
  #}}}

  #{{{ unsubscribe
  describe :unsubscribe do 
    context "when logged off" do 
      it "should deny access" do 
        post "items/#{@item.id}/unsubscribe"
        access_denied(response).should be true
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
        User.any_instance.stub(:schools).and_return(@item.tags)
        @item.subscribers.include?(@user).should be true
        @user.items.include?(@item).should be true
        post "items/#{@item.id}/unsubscribe"
        access_denied(response).should be false
        @item.reload
        @user.reload
        @item.subscribers.include?(@user).should be false
        @user.items.include?(@item).should be false
      end
    end
  end
  #}}}

  #{{{ subscribe
  describe :cart do 
    context "when logged off" do 
      it "should deny access" do 
        post "items/#{@item.id}/cart"
        access_denied(response).should be true
      end
    end

    context "when logged in" do 
      before do 
        login(@user)
      end
      it "should add to cart list" do 
        User.any_instance.stub(:schools).and_return(@item.tags)
        post "items/#{@item.id}/cart"
        JSON.parse(response.body)["id"].should == @item.id.to_s

        @item.reload
        @user.reload
        @user.cart_items.include?(@item).should be true
        @item.interested_users.include?(@user).should be true
      end
    end
  end
  #}}}

  #{{{ uncart
  describe :uncart do 
    context "when logged off" do 
      it "should deny access" do 
        post "items/#{@item.id}/uncart"
        access_denied(response).should be true
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
        User.any_instance.stub(:schools).and_return(@item.tags)
        @item.interested_users.include?(@user).should be true
        @user.cart_items.include?(@item).should be true
        post "items/#{@item.id}/uncart"
        access_denied(response).should be false
        @item.reload
        @user.reload
        @item.interested_users.include?(@user).should be false
        @user.cart_items.include?(@item).should be false
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
        access_denied(@response).should be true
      end
    end
    context "when admin" do 
      before do 
        login(@user)
        User.any_instance.stub(:shapter_admin).and_return(true)
      end
      it "destroy an item" do 
        tags = @item.tags
        tags.select{|t| t.item_ids.include?(@item.id)}.empty?.should be false
        delete "items/#{@item.id}"

        Item.find(@item.id).should be_nil
        tags.select{|t| t.reload ; t.item_ids.include?(@item.id)}.empty?.should be true

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
        access_denied(@response).should be true
      end
    end
    context "when admin" do 
      before do 
        login(@user)
        User.any_instance.stub(:shapter_admin).and_return(true)
      end
      it "updates an item" do 
        new_name = "new name"
        desc = "soooooo cool !"
        new_short_name = "new short name haha"
        put "items/#{@item.id}/update", :item => {:name => new_name, :description => desc, :short_name => new_short_name}

        @item.reload
        @item.name.should == new_name
        @item.description.should == desc
        @item.short_name.should == new_short_name

      end
    end
  end
  #}}}

  #{{{ avg_diag
  describe :avgDiag do 
    it "should present averaged diagram" do 
      login(@user)
      post "items/#{@item.id}/avgDiag"
      (@response.body).should == @item.front_avg_diag.to_json
    end
  end
  #}}}

  describe :comments do 

    #{{{ index
    describe :index do

      context "when logged of" do
        it "denies access" do 
          post "items/#{@item.id}/comments"
          access_denied(@response).should be true
        end
      end

      context "when logged in as student" do 
        before do 
          login(@user)
        end

        it "allows access if item belongs to current_user.school " do 
          @user.schools << @item.tags.last# ; @user.save ; @user.reload

          post "items/#{@item.id}/comments"
          access_denied(@response).should be false
        end

      end

      context "when logged in as admin" do 
        before do 
          login(@user)
          User.any_instance.stub(:shapter_admin).and_return(true)
        end

        it "allows access if item does NOT belong to current_user.school " do 
          post "items/#{@item.id}/comments"
          access_denied(@response).should be false
        end

        it "list items comments" do 
          c = FactoryGirl.build(:comment) ;  c.author = @user
          @item.comments << c
          @item.save ; @item.reload
          post "items/#{@item.id}/comments"
          a = JSON.parse(response.body)
          a.is_a?(Array).should be true
          a.size.should == @item.comments.size
          a.last["id"].should == @item.comments.last.id.to_s
        end

      end
    end
    #}}}

  end

end
