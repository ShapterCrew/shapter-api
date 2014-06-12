require File.join(Rails.root,'config/initializers/aws_credentials.rb')

CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: AWS.config.access_key_id,
    aws_secret_access_key: AWS.config.secret_access_key,
    region: AWS.config.region,
  }

  config.fog_directory = Rails.env.production? ? "shapter-shared-files" : "shapter-dev-shared-files"
  config.fog_public = false
end
