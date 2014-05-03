require 'spec_helper'

describe Shapter::TagsV2 do 

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
        response.body.should == Tag.all.map{|t| {name: t.name, id: t.id.to_s}}.to_json
      end

      context "when filter param is provided" do 
        it "filters when <filter> param is provided" do 
          get "tags", :filter => @schooltag1.name
          a = JSON.parse(response.body)
          a.should =~ [@schooltag1,@t1,@t2].map{|t| {"name" => t.name, "id" => t.id.to_s}}
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
        post "tags/suggested", {:ignore_user => false, :selected_tags => [@tag.id.to_s]}, {"Accept-Version" => "v2"}
        h = JSON.parse(response.body)
        h.has_key?("user_tags").should be_true
        h["user_tags"].should =~ [{"name" => @tag.name, "id" => @tag.id.to_s}]
      end

      it "ignores users's tag when asked" do 
        post "tags/suggested", {:ignore_user => true, :selected_tags => [@tag.id.to_s]}, {"Accept-Version" => "v2"}
        h = JSON.parse(response.body)
        h["user_tags"].blank?.should be_true
      end

      it "provides recommended tags" do 
        post "tags/suggested", {:selected_tags => [@tag.id.to_s]}, {"Accept-Version" => "v2"}
        h = JSON.parse(response.body)
        h.has_key?("recommended_tags").should be_true
      end

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
          post "tags/#{@tag.id}/update", :name => "another_name" 
          access_denied(@response).should be_true
        end
      end

      context "when admin" do 
        before do 
          login(@user)
          User.any_instance.stub(:shapter_admin).and_return(true)
        end

        it "updates name" do 
          post "tags/#{@tag.id}/update", :name => "another_name" 
          access_denied(@response).should be_false
          @tag.reload
          @tag.name.should == "another_name"
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
