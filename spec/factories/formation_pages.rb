# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :formation_page do
    tag_ids {[BSON::ObjectId.new]}
  end
end
