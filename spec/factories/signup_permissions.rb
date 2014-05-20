# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :signup_permission do
    school_name "MySchool"
    email "authorized_user@school.com"
  end
end
