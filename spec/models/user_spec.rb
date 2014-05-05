require 'spec_helper'

describe User do
  before(:each) do 
    User.delete_all
  end


  it "should set and validates school" do 
    u = FactoryGirl.build(:user)
    u.schools = []

    u.valid?.should be_false

    u.email = 'valid@student.ecp.fr'
    u.save
    u.reload
    puts u.errors
    u.valid?.should be_true
    u.schools.first.name.should == "Centrale Paris"

  end

end
