require 'logger'
ActiveSupport::LoggerThreadSafeLevel.include(Logger::Severity) if defined?(ActiveSupport::LoggerThreadSafeLevel)