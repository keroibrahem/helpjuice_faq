# config/initializers/redis.rb


REDIS_CONFIG = {
  production: {
    url: ENV['REDIS_URL'],
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    reconnect_attempts: 5,  
    timeout: 10,           
    logger: Rails.logger    
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
  REDIS = Redis.new(REDIS_CONFIG[Rails.env.to_sym])
  
  if REDIS.ping != "PONG"
    raise "Unexpected response from Redis"
  end
  
  Rails.logger.info "✅  Redis - البيئة: #{Rails.env}"
rescue StandardError => e
  Rails.logger.error "❌ fild Redis: #{e.message}"
  
  if Rails.env.production?
    Sentry.capture_exception(e) if defined?(Sentry)
  else
    
    puts "="*50
    puts "eroor Redis: #{e.message}"
    puts "Ensure that the Redis server is running and the settings are correct."
    puts "Your current settings: #{REDIS_CONFIG[Rails.env.to_sym]}"
    puts "="*50
    raise e unless Rails.env.test?  
  end
end


if defined?(Sidekiq)
  Sidekiq.configure_server do |config|
    config.redis = REDIS_CONFIG[Rails.env.to_sym].merge(namespace: "sidekiq_#{Rails.env}")
  end

  Sidekiq.configure_client do |config|
    config.redis = REDIS_CONFIG[Rails.env.to_sym].merge(namespace: "sidekiq_#{Rails.env}")
  end
end