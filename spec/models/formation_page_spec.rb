require 'spec_helper'

describe FormationPage do

  before(:each) do 
    FormationPage.delete_all
    Tag.delete_all
    User.delete_all
    Item.delete_all

    @t = FactoryGirl.create(:tag)
    @f = FactoryGirl.create(:formation_page)
    @i = FactoryGirl.create(:item)
    @u = FactoryGirl.create(:user)
    @f.tag_ids = [@t.id]
    @f.save
  end

  describe :validations do

  it "factory validates" do 
    expect(@f.valid?).to be true
  end

  it "validates uniqueness of tag_ids" do 
    @f2 = FactoryGirl.build(:formation_page)
    @f2.tag_ids = @f.tag_ids
    expect(@f2.valid?).to eq false
  end

  it "validates presence of tag_ids" do 
    @f.stub(:tag_ids).and_return([])
    expect(@f.valid?).to eq false
  end

  end

  describe :tags do 
    it "find tags" do 
      @f.stub(:tag_ids).and_return([@t.id])
      @f.tags.should eq [@t]
    end
  end

  describe :items do 
    it "find items" do 
      @f.stub(:tag_ids).and_return([@t.id])
      @t.items << @i

      @f.items.should eq [@i]
    end
  end

end
