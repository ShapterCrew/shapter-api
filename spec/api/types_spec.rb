require 'spec_helper'

describe Shapter::V6::Types do
  before do 
    User.delete_all
    Tag.delete_all
    @tag = FactoryGirl.create(:tag)
    @tag2 = Tag.create(name: "haha", type: "hoho")

    @user = FactoryGirl.create(:user)
    User.any_instance.stub(:confirmed_student?).and_return(true)
    login(@user)
  end

  #{{{ index
  describe :index do 

    it "should list all tag types" do 
      get "types"
      JSON.parse(@response.body)["types"].should =~ [@tag,@tag2].map(&:type)
    end

  end
  #}}}

end
