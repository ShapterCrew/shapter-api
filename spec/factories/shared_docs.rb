# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shared_doc do
    name "MyString"
    description "MyString"
    file {Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/150.jpg')))}
  end
end
