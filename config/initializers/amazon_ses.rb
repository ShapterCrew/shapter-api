require File.expand_path('../aws_credentials.rb', __FILE__)
ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
  server: "email.eu-west-1.amazonaws.com",
  access_key_id: AWS.config.access_key_id,
  secret_access_key: AWS.config.secret_access_key
