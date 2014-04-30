require File.expand_path('../aws_credentials.rb', __FILE__)
ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
  region: "eu-west-1",
  access_key_id: AWS.config.access_key_id,
  secret_access_key: AWS.config.secret_access_key
