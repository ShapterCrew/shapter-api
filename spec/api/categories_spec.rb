require 'spec_helper'
describe Shapter::V7::Categories do 

  before(:each) do 
    Category.delete_all
    @c = FactoryGirl.create(:category)
  end

  #{{{ index
  describe :index do 
    
    it "lists all categories" do 
      post "categories"
      h = JSON.parse(@response.body)
      expect( h.has_key?("categories") ).to be true
      expect( h["categories"].first["id"] ).to eq @c.id.to_s
    end

  end
  #}}}

end
