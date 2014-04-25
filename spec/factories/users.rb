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
    school {Tag.create(name: "schoolTag")}
  end
end
