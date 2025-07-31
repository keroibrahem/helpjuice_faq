unless defined?(ActiveSupport::LoggerThreadSafeLevel::Logger)
    require 'logger'
    module ActiveSupport
      module LoggerThreadSafeLevel
        Logger = ::Logger
      end
    end
  end
# تهيئة الـ Logger
Rails.logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new($stdout))