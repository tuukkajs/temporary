require_relative 'boot'

require 'rails/all'
require 'net/ping/tcp'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Temporary
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.encoding = "utf-8"
    config.middleware.insert 0, Rack::UTF8Sanitizer
    config.time_zone = 'Helsinki'
   
     # config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_types = [:datetime, :time]
    config.cache_store = :redis_store, "redis://localhost:6379/0/cache", { expires_in: 8.hours }
    config.autoload_paths += %w(#{config.root}/app/models/ckeditor)
  end
end
