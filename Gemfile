source "https://rubygems.org"

# Core Rails
gem 'rails', '~> 7.0.8'
gem "propshaft"


# Critical dependencies
gem 'bigdecimal', '~> 3.1.4', require: false
gem 'logger', '~> 1.5'
gem 'activesupport', '7.0.8.7'

# Database
gem "pg", "~> 1.1", group: :production

# Server
gem "puma", "~> 6.0"
gem "redis", "~> 5.0"
gem "hiredis", "~> 0.6"
gem "redis-rails"

# Background processing
gem "sidekiq", "~> 7.0"
gem "sidekiq-failures", "~> 1.0"

# Caching
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Windows support
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Performance
gem "bootsnap", "~> 1.16", require: false
gem "thruster", require: false
gem "jbuilder"

# Deployment
gem "kamal", require: false
gem "rails_12factor", group: :production

# Testing
group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "rspec-rails", "~> 7.1.1"
end

# Development
group :development do
  gem "web-console"
  gem "debug", "~> 1.7", platforms: %i[ mri windows ], require: "debug/prelude"
end

# Development and test
group :development, :test do
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end