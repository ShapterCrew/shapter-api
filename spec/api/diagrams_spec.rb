require 'spec_helper'

describe Shapter::V7::Diagrams do 

  before(:each) do 
    Item.delete_all
    User.delete_all
    Tag.delete_all

    @item = FactoryGirl.create(:item)
    @item.tags << Tag.find_or_create_by(name: "Centrale Lyon")
    @user = FactoryGirl.create(:user)
    login(@user)
  end

  #{{{ create or update
  describe "create_or_update" do 
    it "creates or updates a diagram" do 
      @item.diagrams.count.should == 0

      put "/items/#{@item.id}/mydiagram", :values => {0 => 0, "1" => 2, 3 => 6}

      @item.reload
      @item.diagrams.count.should == 1
      d = @item.diagrams.first

      d.author.should == @user
      d.values[0].should == 0
      d.values[1].should == 2
      d.values[2].should == nil
      d.values[3].should == 6


      put "/items/#{@item.id}/mydiagram", :values => {0 => 0, 1 => 3, 3 => 9}

      @item.reload
      @item.diagrams.count.should == 1
      d = @item.diagrams.first

      d.author.should == @user
      d.values[0].should == 0
      d.values[1].should == 3
      d.values[2].should == nil
      d.values[3].should == 9
    end

  end
  #}}}

  #{{{ delete
  describe "delete" do 

    it "deletes a diagram" do 
      d = FactoryGirl.build(:diagram)
      d.author = @user
      d.item = @item

      d.save

      d.reload ; @item.reload
      @item.diagrams.count.should == 1

      delete "items/#{@item.id}/mydiagram"

      @item.reload

      @item.diagrams.count.should == 0
    end

  end
  #}}}

  #{{{ get
  describe "get" do 

    it "gets a diagram" do 
      d = FactoryGirl.build(:diagram)
      d.author = @user
      d.item = @item

      d.save

      d.reload ; @item.reload

      post "items/#{@item.id}/mydiagram"

      h = JSON.parse(response.body)
      h["id"].should == d.id.to_s
    end

  end
  #}}}

end
