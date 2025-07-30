REDIS = Redis.new(
  host: 'localhost',
  port: 6379,
  driver: :ruby,
  reconnect_attempts: 3,
  timeout: 5
)

# اختبار الاتصال
begin
  REDIS.ping
  Rails.logger.info "Successfully connected to Redis"
rescue Redis::CannotConnectError => e
  Rails.logger.error "Redis connection failed: #{e.message}"
  raise unless Rails.env.development?
end