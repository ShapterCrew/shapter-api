require 'spec_helper'

describe SharedDoc do
  before do
    User.delete_all
    Item.delete_all
    SharedDoc.delete_all

    @user = FactoryGirl.create(:user)
    @item = FactoryGirl.create(:item)
    @doc = FactoryGirl.build(:shared_doc)
    @doc.item = @item
    @doc.author = @user
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
    puts "debug: #{@doc.errors.messages}"
    @doc.valid?.should be_true
  end

end
