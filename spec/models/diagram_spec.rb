require 'spec_helper'

describe Diagram do

  describe :+ do 
    it "add should add all variables" do 
      d1 = Diagram.new(x0: 1, x1: 2       )
      d2 = Diagram.new(x0: 1       , x3: 3)

      dd = d1 + d2
      dd.x0.should == 2
      dd.x1.should == 2
      dd.x2.should == nil
      dd.x3.should == 3
    end
  end
end
