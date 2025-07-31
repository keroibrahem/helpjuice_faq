REDIS_CONFIG = {
  production: {
    url: ENV['REDIS_URL'],
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    reconnect_attempts: 5,
    timeout: 10
  },
  development: {
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
    timeout: 5
  },
  test: {
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1')
  }
}.freeze

begin
  REDIS = Redis.new(REDIS_CONFIG[Rails.env.to_sym].except(:logger))
  
  if REDIS.ping != "PONG"
    raise "Unexpected response from Redis"
  end
  
  Rails.logger.info "✅ Redis connected - Environment: #{Rails.env}"
rescue StandardError => e
  Rails.logger.error "❌ Redis connection failed: #{e.message}"
  
  if Rails.env.production?
    Sentry.capture_exception(e) if defined?(Sentry)
  else
    puts "="*50
    puts "Redis Error: #{e.message}"
    puts "Current settings: #{REDIS_CONFIG[Rails.env.to_sym]}"
    puts "Ensure Redis server is running at the specified URL"
    puts "="*50
    raise e unless Rails.env.test?
  end
end

if defined?(Sidekiq)
  Sidekiq.configure_server do |config|
    config.redis = REDIS_CONFIG[Rails.env.to_sym].except(:logger).merge(
      namespace: "sidekiq_#{Rails.env}",
      size: ENV.fetch('RAILS_MAX_THREADS', 5)
    )
  end

  Sidekiq.configure_client do |config|
    config.redis = REDIS_CONFIG[Rails.env.to_sym].except(:logger).merge(
      namespace: "sidekiq_#{Rails.env}"
    )
  end
end