require 'upstash/redis'

begin
  REDIS = Upstash::Redis.new(
    url: ENV['UPSTASH_REDIS_REST_URL'],
    token: ENV['UPSTASH_REDIS_REST_TOKEN']
  )
  
  if REDIS.ping != "PONG"
    raise "Unexpected response from Redis"
  end

  Rails.logger.info "✅ Redis connected to Upstash - Environment: #{Rails.env}"
rescue StandardError => e
  Rails.logger.error "❌ Redis connection failed: #{e.message}"
  
  if Rails.env.production?
    Sentry.capture_exception(e) if defined?(Sentry)
  else
    puts "=" * 50
    puts "Redis Error: #{e.message}"
    puts "Ensure UPSTASH_REDIS_REST_URL and UPSTASH_REDIS_REST_TOKEN are set"
    puts "=" * 50
    raise e unless Rails.env.test?
  end
end

if defined?(Sidekiq)
  Sidekiq.configure_server do |config|
    config.redis = {
      url: ENV['UPSTASH_REDIS_REST_URL'],
      token: ENV['UPSTASH_REDIS_REST_TOKEN'],
      namespace: "sidekiq_#{Rails.env}"
    }
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: ENV['UPSTASH_REDIS_REST_URL'],
      token: ENV['UPSTASH_REDIS_REST_TOKEN'],
      namespace: "sidekiq_#{Rails.env}"
    }
  end
end
