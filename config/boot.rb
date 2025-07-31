ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

# Early logger initialization
unless defined?(ActiveSupport::LoggerThreadSafeLevel::Logger)
  require 'logger'
  module ActiveSupport
    module LoggerThreadSafeLevel
      Logger = ::Logger
    end
  end
end

require "bundler/setup"
require "bootsnap/setup"