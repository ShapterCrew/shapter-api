require 'spec_helper'

describe SharedDoc do
  before do
    Item.delete_all
    SharedDoc.delete_all
    @item = FactoryGirl.create(:item)
    @doc = FactoryGirl.build(:shared_doc)
    @doc.item = @item
  end

  it "checks presence of file" do 
    SharedDoc.new(@doc.attributes.merge({file: nil})).valid?.should be_false
  end

  it "checks presence of item" do 
    SharedDoc.new(@doc.attributes.merge({item: nil})).valid?.should be_false
  end

  it "checks presence of name" do
    SharedDoc.new(@doc.attributes.merge({name: nil})).valid?.should be_false
  end

  it "validates" do 
    @doc.valid?.should be_true
  end

end
