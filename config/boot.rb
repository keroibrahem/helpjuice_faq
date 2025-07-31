ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

# Early requires
require 'mutex_m'
require 'logger'

# Logger setup
module ActiveSupport
  module LoggerThreadSafeLevel
    include Logger::Severity
  end
end

require "bundler/setup"
require "bootsnap/setup"