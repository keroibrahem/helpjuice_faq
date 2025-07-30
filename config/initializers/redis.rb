REDIS = Redis.new(
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
  reconnect_attempts: 3,
  timeout: 5,
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
)

# اختبار الاتصال عند التشغيل
begin
  if REDIS.ping != "PONG"
    raise "Unexpected Redis response"
  end
  Rails.logger.info "✅ Successfully connected to Redis"
rescue StandardError => e
  Rails.logger.error "❌ Redis connection failed: #{e.message}"
  if Rails.env.production?
    Sentry.capture_exception(e)
  else
    raise e
  end
end