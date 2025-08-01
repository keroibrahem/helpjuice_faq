redis_config = {
  url: ENV['REDIS_URL'],
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
  reconnect_attempts: 3,
  timeout: 5,
  namespace: "sidekiq_#{Rails.env}"
}

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
