# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email "foo@bar.com"
    firstname "Jean Patrick"
    lastname "Trololo"
    password "oijoijoij"
    password_confirmation "oijoijoij"
    confirmed_at Date.yesterday
    shapter_admin false
    schools {[Tag.find_or_create_by(name: "school")]}
  end
end
