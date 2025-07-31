require_relative "boot"

# Load logger before Rails
require 'logger'
module ActiveSupport
  module LoggerThreadSafeLevel
    Logger = ::Logger
  end
end

require "rails/all"

Bundler.require(*Rails.groups)

module HelpjuiceFaq
  class Application < Rails::Application
    config.load_defaults 7.0
    
    # Ensure logger is properly initialized
    config.before_configuration do
      Rails.logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))
    end

    # Your existing configuration...
    config.autoload_paths << Rails.root.join("lib")
    config.cache_store = :redis_cache_store, {
      url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
      reconnect_attempts: 3,
      error_handler: -> (method:, returning:, exception:) {
        Rails.logger.error("Redis error: #{exception.message}")
      }
    }
  end
end