# config/initializers/00_logger.rb
require 'logger'

module ActiveSupport
  module LoggerThreadSafeLevel
    Logger = ::Logger
  end
end

Rails.logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT))