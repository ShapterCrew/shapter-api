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
end
