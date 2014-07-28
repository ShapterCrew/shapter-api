require 'spec_helper'

describe Shapter::V7::Tags do 

  before(:each) do 
    User.any_instance.stub(:confirmed_student?).and_return(:true)
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
        post "tags"
        access_denied(@response).should be true
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
        post "tags"
        access_denied(@response).should be false
      end

      it "list all tags withoug params" do 
        post "tags"
        JSON.parse(response.body).map{|h| h["id"]}.map(&:to_s).should =~ Tag.all.map(&:id).map(&:to_s)
      end

      context "when filter param is provided" do 
        it "filters when <filter> param is provided" do 
          post "tags", :filter => @schooltag1.id
          a = JSON.parse(response.body)
          a.map{|h| h["id"]}.map(&:to_s).should =~ [@schooltag1,@t1,@t2].map{|h| h["id"]}.map(&:to_s)
        end

        it "returns empty array if nothing is found" do 
          post "tags", :filter => "hahahanonono"
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
        post 'tags/suggested'
        access_denied(@response).should be true
      end
    end

    context "when logged in" do 
      before do 
        login(@user)
      end

      it "allows access" do 
        post 'tags/suggested', :filter => []
        access_denied(@response).should be false
      end

      it "provides recommended tags" do 
        post "tags/suggested", {:selected_tags => [@tag.id.to_s]}
        h = JSON.parse(response.body)
        h.has_key?("recommended_tags").should be true
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
      @i2.tags.map(&:name).include?("batchAddedTag").should be true
      @i3.tags.map(&:name).include?("batchAddedTag").should be true
      @i4.tags.map(&:name).include?("batchAddedTag").should be true

      t = Tag.find_by(name: "batchAddedTag")
      t.items.include?(@i2).should be true
      t.items.include?(@i3).should be true
      t.items.include?(@i4).should be true
    end

    it "find and add a tag to multiple items when tag already exists" do 
      post "tags/batch_tag", {:item_ids_list => [@i2,@i3,@i4].map(&:id).map(&:to_s), :tag_name => @tag.name}
      [@i2,@i3,@i4].each(&:reload)
      @i2.tags.include?(@tag).should be true
      @i3.tags.include?(@tag).should be true
      @i4.tags.include?(@tag).should be true

      @tag.reload
      @tag.items.include?(@i2).should be true
      @tag.items.include?(@i3).should be true
      @tag.items.include?(@i4).should be true
    end
  end
  #}}}

  describe :tag_id do 

    #{{{ students
    describe :students do 
      before do 
        login(@user)
        User.any_instance.stub(:shapter_admin).and_return(false)
      end

      it "get students" do 
        @tag.students << @user
        post "tags/#{@tag.id}/students", entities: {user: {firstname: true, lastname: true}}
        h = JSON.parse(@response.body)
        h.has_key?("students").should be true
        hh = h["students"].first
        hh.has_key?("firstname").should be true
        hh.has_key?("lastname").should be true
        hh.has_key?("id").should be true
        hh["id"].should == @user.id.to_s
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
          put "tags/#{@tag.id}", :name => "another_name"
          access_denied(@response).should be true
        end
      end

      context "when admin" do 
        before do 
          login(@user)
          User.any_instance.stub(:shapter_admin).and_return(true)
        end

        it "updates name" do 
          put "tags/#{@tag.id}", :name => "another_name" 
          access_denied(@response).should be false
          @tag.reload
          @tag.name.should == "another_name"
        end

        it "updates short_name" do 
          put "tags/#{@tag.id}", :short_name => "another_description" 
          access_denied(@response).should be false
          @tag.reload
          @tag.short_name.should == "another_description"
          @tag.name.blank?.should be false
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
          access_denied(@response).should be true
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
          @item.tag_ids.include?(@tag.id).should be true
          delete "tags/#{@tag.id}"
          @item.reload
          @item.tag_ids.include?(@tag.id).should be false
        end

      end
    end
    #}}}

  end

end
