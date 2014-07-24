require 'spec_helper'

describe Diagram do

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
end
