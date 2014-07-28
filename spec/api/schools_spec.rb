require "spec_helper"
describe Shapter::V7::Schools do 
  before(:each) do 
    Tag.delete_all
    Category.delete_all

    @t = FactoryGirl.create(:tag)
    @c = Category.create(code: "school")
    @t.category = @c ; @t.save
  end

  describe :index do 
    it 'lists all schools' do 

      post "schools"
      h = JSON.parse(@response.body)
      
      expect( h.has_key?("schools")).to be true
      expect( h["schools"].any?).to be true
      expect( h["schools"].first.has_key?("id")).to be true
      expect( h["schools"].first["id"]).to eq @t.id.to_s

    end
  end

end
