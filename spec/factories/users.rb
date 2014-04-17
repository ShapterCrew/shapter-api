# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email "foo@bar.com"
    firstname "Jean Patrick"
    lastname "Trololo"
    password "oijoijoij"
    password_confirmation "oijoijoij"
  end
end
