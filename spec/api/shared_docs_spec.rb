require 'spec_helper'

describe Shapter::V5::SharedDocs do 
  before(:each) do 
    Item.delete_all
    SharedDoc.delete_all
    User.delete_all

    User.any_instance.stub(:confirmed_student?).and_return(:true)
    @user = FactoryGirl.create(:user)
    login(@user)

    @item = FactoryGirl.create(:item)

    @shared_doc = FactoryGirl.build(:shared_doc)
    @shared_doc.item = @item
    @item.shared_docs << @shared_doc
    @shared_doc.save
    @item.save

    @ps = {
      :name => 'foo',
      :description => 'bar',
      :file => Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/150.jpg')))
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

      SharedDoc.count.should == 1
      post "items/#{@item.id}/sharedDocs/", :sharedDoc => @ps
      SharedDoc.count.should == 2
      s = SharedDoc.all.sort_by(&:created_at).last

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

      @shared_doc.reload
      @shared_doc.name.should == @ps[:name]
      @shared_doc.description.should == @ps[:description]
    end
  end
  #}}}

  #{{{ delete
  describe :delete do 
    it 'deletes document' do 
      SharedDoc.count.should == 1
      delete "items/#{@item.id}/sharedDocs/#{@shared_doc.id}"
      SharedDoc.count.should == 0
    end
  end
  #}}}

end
