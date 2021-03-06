ShapterApi::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  #config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Don't send emails
  config.action_mailer.perform_deliveries = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  config.action_mailer.default_url_options = { :host => 'localhost'}
  #config.action_mailer.delivery_method = :ses

  #use this to truly debug email sending:
  #config.action_mailer.default_url_options = { :host => 'shapter.com'}
  #config.action_mailer.perform_deliveries = true #try to force sending in development 
  #config.action_mailer.raise_delivery_errors = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  config.cache_store = :redis_store, 'redis://localhost:6379/1/shapter_api_cache', { expires_in: 10.minutes }
  config.action_controller.perform_caching = true
end
