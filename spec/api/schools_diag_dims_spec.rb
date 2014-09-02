require "spec_helper"
describe Shapter::V7::SchoolsDiagDims do 
  before(:each) do 
    User.delete_all
    Tag.delete_all
    Category.delete_all

    @t = FactoryGirl.create(:tag)
    @i = FactoryGirl.create(:item)

    @t.items << @i
    @t.update_attributes(category_id: Category.create(code: "school").id)

    @user = FactoryGirl.create(:user)
    login(@user)
    User.any_instance.stub(:shapter_admin).and_return(true)

  end

  describe :update do 

    it 'should update' do 
      #@t.custom_diag_dims.should == Diagram.default_dims
      @d = FactoryGirl.build(:diagram)
      @d.item = @i
      expect(@d.instance_eval{front_dims}).to eq Diagram.default_dims
      put "schools/#{@t.id}/diag_dims", :index_array => [1,2,3]
      @t.reload
      expect(@d.instance_eval{front_dims}).to eq [1,2,3]
    end

  end

end
