# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    content "MyText"
    author "123"
    work_score 1
    quality_score 2
  end
end
