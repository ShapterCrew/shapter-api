require 'spec_helper'

describe User do
  before(:each) do 
    User.delete_all
    SignupPermission.delete_all
  end


  #it "should set and validates school using regex" do 
  #  u = FactoryGirl.build(:user)
  #  u.schools = []

  #  u.valid?.should be false

  #  u.email = 'valid@student.ecp.fr'
  #  u.save
  #  u.reload
  #  u.valid?.should be true
  #  u.schools.first.name.should == "Centrale Paris"

  #end

  #it "should set and validates school using signup_permission" do 
  #  u = FactoryGirl.build(:user)
  #  u.schools = []
  #  u.firstname = nil
  #  u.valid?.should be false

  #  SignupPermission.create(email: "foo@bar.com", school_names: ["fooSchool","barSchool"], firstname: 'fname')

  #  u.email = "foo@bar.com"

  #  u.save ; u.reload
  #  u.valid?.should be true
  #  u.schools.first.name.should == "fooSchool"
  #  u.schools.last.name.should == "barSchool"
  #  u.firstname.should == 'fname'
  #end

end
