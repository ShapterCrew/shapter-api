require 'spec_helper'

describe SharedDoc do
  before do
    User.delete_all
    Item.delete_all
    SharedDoc.delete_all

    @user = FactoryGirl.create(:user)
    @item = FactoryGirl.create(:item)

    @valid_attr = {
      file: Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/150.jpg'))),
      item: @item,
      author: @user,
      name: "haha",
    }
  end

  it "checks presence of file" do 
    SharedDoc.new(@valid_attr.merge({file: nil})).valid?.should be false
  end

  it "checks presence of item" do 
    SharedDoc.new(@valid_attr.merge({item: nil})).valid?.should be false
  end

  it "checks presence of name" do
    SharedDoc.new(@valid_attr.merge({name: nil})).valid?.should be false
  end

  it "validates" do 
    SharedDoc.new(@valid_attr).valid?.should be true
  end

  it "new doc has 0 dl_count" do 
    d = SharedDoc.new(@valid_attr)
    d.save
    d.reload
    d.dl_count.should == 0
  end

end
