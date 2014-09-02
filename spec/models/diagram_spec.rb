require 'spec_helper'

describe Diagram do
  before(:each) do 
    Tag.delete_all
    Item.delete_all
    Category.delete_all
  end

  describe :+ do 
    it "add should add all variables" do 
      d1 = Diagram.new(values: [1, 2  , nil, nil])
      d2 = Diagram.new(values: [1, nil, nil, 3])

      dd = d1 + d2
      dd.values[0].should == 2
      dd.values[1].should == 2
      dd.values[2].should == nil
      dd.values[3].should == 3
    end
  end

  describe :validations do 
    before do 
    u = FactoryGirl.build(:user)
    @d = FactoryGirl.build(:diagram)
    @d.author = u
    end

    it "should validate" do 
      @d.valid?.should be true
    end

    it "should validate author" do 
      @d.author = nil
      @d.valid?.should be false
    end

    it "should validate values" do 
      @d.values = nil
      @d.valid?.should be false
    end
  end

  describe :front_values do 
    it "should have default values" do 
      @d = FactoryGirl.build(:diagram)
      @d.item = FactoryGirl.build(:item)
      expect(@d.instance_eval{front_dims}).to eq [ 0,4,5,6,7,9,12 ]
    end

    it "should have school tag values when available" do 
      @t = FactoryGirl.create(:tag) 
      @t.category = Category.create(code: :school)
      @t.custom_diag_dims = [1,2,3]

      @i = FactoryGirl.create(:item)
      @i.tags << @t

      @t.save ; @i.save

      @d = FactoryGirl.build(:diagram)
      @d.item = @i

      expect(@d.instance_eval{front_dims}).to eq [ 1,2,3 ]
    end
  end

end
