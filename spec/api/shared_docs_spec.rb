require 'spec_helper'

describe Shapter::V5::SharedDocs do 
  before(:each) do 
    Item.delete_all
    User.delete_all

    User.any_instance.stub(:confirmed_student?).and_return(:true)
    @user = FactoryGirl.create(:user)
    login(@user)

    @item = FactoryGirl.create(:item)

    @shared_doc = FactoryGirl.build(:shared_doc)
    @shared_doc.item = @item
    @shared_doc.author = @user
    @shared_doc.save

    @ps = {
      :name => 'foo',
      :description => 'bar',
      :file => "head, #{Base64.encode64("hahalol")}",
      :filename => "haha.jpg"
    }
  end

  #{{{ index
  describe :index do 
    it "list all shared docs associated to an item" do 
      get "items/#{@item.id}/sharedDocs"
      r = JSON.parse(@response.body)
      r.has_key?('shared_docs').should be_true
      r["shared_docs"].map{|h| h["id"].to_s}.should =~ @item.shared_docs.map(&:pretty_id)
    end
  end
  #}}}

  #{{{ get
  describe :get do 
    context 'when available' do 
      it 'finds object' do 
        get "items/#{@item.id}/sharedDocs/#{@shared_doc.id}"
        JSON.parse(@response.body)["id"].should == @shared_doc.id.to_s
      end
    end

    context 'when not found' do 
      it 'returns 404' do 
        get "items/#{@item.id}/sharedDocs/nopenopenopenope"
        @response.status.should == 404
      end
    end
  end
  #}}}

  #{{{ create
  describe :create do 
    it 'creates document if valid' do 

      @item.shared_docs.count.should == 1
      post "items/#{@item.id}/sharedDocs/", :sharedDoc => @ps.merge(item: @item, author: @user)
      @item.reload
      @item.shared_docs.count.should == 2
      s = @item.shared_docs.sort_by(&:created_at).last

      s.name.should == @ps[:name]
      s.description.should == @ps[:description]
    end
  end
  #}}}

  #{{{ update
  describe :udpate do 
    it 'updates document attributes' do 
      @shared_doc.name.should_not == @ps[:name]
      @shared_doc.description.should_not == @ps[:description]

      put "items/#{@item.id}/sharedDocs/#{@shared_doc.id}", :sharedDoc => @ps

      @shared_doc.reload ; @item.reload
      @shared_doc.name.should == @ps[:name]
      @shared_doc.description.should == @ps[:description]
    end
  end
  #}}}

  #{{{ delete
  describe :delete do 
    it 'deletes document' do 
      @item.shared_docs.count.should == 1
      delete "items/#{@item.id}/sharedDocs/#{@shared_doc.id}"
      @item.reload
      @item.shared_docs.count.should == 0
    end
  end
  #}}}

  #{{{ score
  describe :score do 

      it "should add to likers when +1" do 
        put "items/#{@item.id}/sharedDocs/#{@shared_doc.id}/score", :score => 1
        @shared_doc.reload ; @item.reload
        @shared_doc.likers.include?(@user).should be_true
        @shared_doc.dislikers.include?(@user).should be_false
      end

      it "should add to dislikers when -1" do 
        put "items/#{@item.id}/sharedDocs/#{@shared_doc.id}/score", :score => -1
        @shared_doc.reload ; @item.reload
        @shared_doc.likers.include?(@user).should be_false
        @shared_doc.dislikers.include?(@user).should be_true
      end

      it "should remove from like/dislikers when 0" do 
        put "items/#{@item.id}/sharedDocs/#{@shared_doc.id}/score", :score => 1
        put "items/#{@item.id}/sharedDocs/#{@shared_doc.id}/score", :score => 0
        @shared_doc.reload ; @item.reload
        @shared_doc.likers.include?(@user).should be_false
        @shared_doc.dislikers.include?(@user).should be_false
      end

      it "should error when score is not in [-1,0,1]" do 
        put "items/#{@item.id}/sharedDocs/#{@shared_doc.id}/score", :score => 3
        @response.status.should == 500
        @response.body.should == {error: "invalid score parameter"}.to_json
      end

  end
  #}}}

  #{{{ dl_count
  describe :countDl do 
    it "add +1 to the counter" do 
      c = @shared_doc.dl_count
      post "items/#{@item.id}/sharedDocs/#{@shared_doc.id}/countDl"
      @shared_doc.reload
      @shared_doc.dl_count.should == (c + 1)
    end
  end
  #}}}

end
