require 'spec_helper'
describe Shapter::V7::Schools do 
  before(:each) do 
    Category.delete_all
    Tag.delete_all

    @t = FactoryGirl.create(:tag)
    @c = Category.create(code: "school")

    @t.update_attribute(:category, @c)
  end

  describe :index do 
    it "list schools" do 
      post "schools/index"
      h = JSON.parse(@response.body)
      expect(h.has_key?("schools")).to be true
      expect(h["schools"].first["id"]).to eq @t.id.to_s
    end
  end

  describe :school_id do 

    describe :get do 
      it "gets the asked school" do 
        post "schools/#{@t.id}"
        h = JSON.parse(@response.body)
        expect(h["id"]).to eq @t.id.to_s
      end

      it "does not find a non-school tag" do 
        Tag.any_instance.stub(:is_school?).and_return(false)
        post "schools/#{@t.id}"
        @response.status.should == 406
      end
    end

    describe :update do 
    end

  end


end
