# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    content "MyText"
    author "123"
    context "dans le cadre de la journée mondiale du tricot"
  end
end
