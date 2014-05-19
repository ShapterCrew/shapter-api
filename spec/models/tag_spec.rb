require 'spec_helper'

describe Tag do
  before(:each) do 
    Tag.delete_all
    Item.delete_all

    @t1 = FactoryGirl.build(:tag) ; @t1.name = "t1" ; @t1.save
    @t2 = FactoryGirl.build(:tag) ; @t2.name = "t2" ; @t2.save

    @i1 = FactoryGirl.create(:item) ; @i1.tags << @t1 ; @i1.save
    @i2 = FactoryGirl.create(:item) ; @i2.tags << @t2 ; @i2.save
  end

  describe "class methods" do

    describe "merge tags" do 
      it "should merge tags" do 
        @i1.tags.should == [@t1]
        @i2.tags.should == [@t2]

        @t1.items.should == [@i1]
        @t2.items.should == [@i2]

        (@t1 == @t2).should be_false

        Tag.merge!(@t1,@t2)

        @t1.reload
        @i1.reload
        @i2.reload
        
        # tag has items
        @t1.items.map(&:id).should =~ [@i1,@i2].map(&:id)

        # items have tag
        @i1.tags.should == [@t1]
        @i2.tags.should == [@t1]

        Tag.where(name: @t1.name).count.should == 1
        Tag.where(name: @t2.name).count.should == 0
      end
    end

  end


end
