require 'spec_helper'
describe Shapter::V7::FormationPage do

  before(:each) do 
    User.delete_all
    FormationPage.delete_all
    @f = FactoryGirl.create(:formation_page)
    @t = FactoryGirl.create(:tag)
    @user = FactoryGirl.create(:user)
    login(@user)
  end

  describe :get do 
    it "finds proper formation when it exists" do 
    @f.update_attribute(:tag_ids, [@t.id])

    post "formations", :tag_ids => [@t.id.to_s]
    h = JSON.parse(@response.body)

    expect(h.has_key?("id")).to be true
    expect(h["id"]).to eq @f.id.to_s
    end

    it "creates new formation when not found" do 
      FormationPage.delete_all
      post "formations", :tag_ids => [@t.id.to_s]
      h = JSON.parse(@response.body)

      expect(h.has_key?("id")).to be true
    end
  end

  describe :typical_users do 
    it "works" do 
      post "formations/typical_users", :tag_ids => [@t.id.to_s]
      h = JSON.parse(@response.body)
      expect(h.has_key?("typical_users")).to be true
      expect(h["typical_users"].is_a? Array).to be true
    end
  end

end
