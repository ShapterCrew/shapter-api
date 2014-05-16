# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :diagram do
    values { (0..Diagram.values_size).to_a }
  end
end
