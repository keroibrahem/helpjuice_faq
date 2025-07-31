require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Basic Configuration
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.force_ssl = true
  config.assume_ssl = true

  # Cache Configuration
  config.action_controller.perform_caching = true
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'],
    namespace: 'cache',
    expires_in: 1.day,
    compress: true,
    pool_size: ENV.fetch('RAILS_MAX_THREADS', 5)
  }

  # Assets Configuration
  config.assets.compile = false
  config.assets.digest = true
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.year.to_i}"
  }

  # Security Configuration
  config.require_master_key = true
  config.active_storage.service = :local
  config.action_mailer.default_url_options = { host: ENV.fetch('APP_HOST', 'example.com') }

  # Logging Configuration
  config.logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new($stdout))
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.log_tags = [:request_id]
  config.silence_healthcheck_path = "/up"

  # Database Configuration
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [:id]

  # Background Jobs
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Error Handling
  config.active_support.report_deprecations = false
end