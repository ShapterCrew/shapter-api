require 'spec_helper'

describe Shapter::V4::Tags do 

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
        @t1 = Tag.new(name: "t1")
        @t2 = Tag.new(name: "t2")
        @t3 = Tag.new(name: "t3")

        @school1 = Item.new(name: "school1")
        @school2 = Item.new(name: "school2")

        @schooltag1 = Tag.new(name: "school1")
        @schooltag2 = Tag.new(name: "school2")

        @school1.tags = [ @schooltag1, @t1,@t2]
        @school2.tags = [ @schooltag2, @t1,@t3]
        [@schooltag1,@schooltag2,@school1,@school2,@t3,@t2,@t1].map(&:save)
        [@schooltag1,@schooltag2,@school1,@school2,@t3,@t2,@t1].map(&:reload)
      end

      it "allows access" do 
        get "tags"
        access_denied(response).should be_false
      end

      it "list all tags withoug params" do 
        get "tags"
        JSON.parse(response.body).map{|h| h["id"]}.map(&:to_s).should =~ Tag.all.map(&:id).map(&:to_s)
      end

      context "when filter param is provided" do 
        it "filters when <filter> param is provided" do 
          get "tags", :filter => @schooltag1.name
          a = JSON.parse(response.body)
          a.map{|h| h["id"]}.map(&:to_s).should =~ [@schooltag1,@t1,@t2].map{|h| h["id"]}.map(&:to_s)
        end

        it "returns empty array if nothing is found" do 
          get "tags", :filter => "hahahanonono"
          response.body.should == [].to_json
        end
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
        post "tags/suggested", {:ignore_user => false, :selected_tags => [@tag.id.to_s]}, {"Accept-Version" => "v3"}
        h = JSON.parse(response.body)
        h.has_key?("user_tags").should be_true
        h["user_tags"].map{|h| h["id"]}.should =~ [@tag.id.to_s]
      end

      it "ignores users's tag when asked" do 
        post "tags/suggested", {:ignore_user => true, :selected_tags => [@tag.id.to_s]}, {"Accept-Version" => "v3"}
        h = JSON.parse(response.body)
        h["user_tags"].blank?.should be_true
      end

      it "provides recommended tags" do 
        post "tags/suggested", {:selected_tags => [@tag.id.to_s]}, {"Accept-Version" => "v3"}
        h = JSON.parse(response.body)
        h.has_key?("recommended_tags").should be_true
      end

    end

  end
  #}}}

  #{{{ batch_tag
  describe "batch_tag" do 
    before do 
      login(@user)
      User.any_instance.stub(:shapter_admin).and_return(:true)
      @i2 = FactoryGirl.create(:item)
      @i3 = FactoryGirl.create(:item)
      @i4 = FactoryGirl.create(:item)
    end
    it "add a tag to multiple items when tag doesn't exist yet" do 
      post "tags/batch_tag", {:item_ids_list => [@i2,@i3,@i4].map(&:id).map(&:to_s), :tag_name => "batchAddedTag"}
      [@i2,@i3,@i4].each(&:reload)
      @i2.tags.map(&:name).include?("batchAddedTag").should be_true
      @i3.tags.map(&:name).include?("batchAddedTag").should be_true
      @i4.tags.map(&:name).include?("batchAddedTag").should be_true

      t = Tag.find_by(name: "batchAddedTag")
      t.items.include?(@i2).should be_true
      t.items.include?(@i3).should be_true
      t.items.include?(@i4).should be_true
    end

    it "find and add a tag to multiple items when tag already exists" do 
      post "tags/batch_tag", {:item_ids_list => [@i2,@i3,@i4].map(&:id).map(&:to_s), :tag_name => @tag.name}
      [@i2,@i3,@i4].each(&:reload)
      @i2.tags.include?(@tag).should be_true
      @i3.tags.include?(@tag).should be_true
      @i4.tags.include?(@tag).should be_true

      @tag.reload
      @tag.items.include?(@i2).should be_true
      @tag.items.include?(@i3).should be_true
      @tag.items.include?(@i4).should be_true
    end
  end
  #}}}

  describe :tag_id do 

    #{{{ update
    describe :update do 
      context "when not admin" do 
        before do 
          login(@user)
          User.any_instance.stub(:shapter_admin).and_return(false)
        end

        it "denies access" do 
          put "tags/#{@tag.id}", :name => "another_name"
          access_denied(@response).should be_true
        end
      end

      context "when admin" do 
        before do 
          login(@user)
          User.any_instance.stub(:shapter_admin).and_return(true)
        end

        it "updates name" do 
          put "tags/#{@tag.id}", :name => "another_name" 
          access_denied(@response).should be_false
          @tag.reload
          @tag.name.should == "another_name"
        end

        it "updates description" do 
          put "tags/#{@tag.id}", :description => "another_description" 
          access_denied(@response).should be_false
          @tag.reload
          @tag.description.should == "another_description"
          @tag.name.blank?.should be_false
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
          delete "tags/#{@tag.id}"
          access_denied(@response).should be_true
        end
      end

      context "when admin" do 
        before do 
          login(@user)
          User.any_instance.stub(:shapter_admin).and_return(:false)
        end

        it "deletes the tag" do 
          delete "tags/#{@tag.id}"
          Tag.find(@tag.id).should be_nil
        end

        it "removes pointer from previously tagged items" do 
          @item.tag_ids.include?(@tag.id).should be_true
          delete "tags/#{@tag.id}"
          @item.reload
          @item.tag_ids.include?(@tag.id).should be_false
        end

      end
    end
    #}}}

  end

end
