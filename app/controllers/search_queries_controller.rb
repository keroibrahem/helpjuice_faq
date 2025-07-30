
# class SearchQueriesController < ApplicationController
#   RATE_LIMIT = 10 # requests per minute
#   SEARCH_DEBOUNCE = 2.seconds

#   before_action :validate_query, only: [:create]
#   before_action :check_rate_limit, only: [:create]

#   def create
#     query = params[:query].strip
#     ip = request.remote_ip

#     # Store in Redis with expiration
#     redis_key = "search_session:#{ip}"
#     store_in_redis(redis_key, query)

#     # Process in background
#     SearchQueryJob.perform_later(query, ip)

#     render json: { status: 'success' }
#   end

#   def analytics
#     ip = request.remote_ip
#     analytics = Rails.cache.fetch("analytics/#{ip}", expires_in: 30.seconds) do
#       SearchQuery.user_search_analytics(ip).merge(redis_queries(ip))
#     end

#     render json: analytics
#   end

#   private

#   def validate_query
#     query = params[:query].to_s.strip
#     return if query.length >= 3

#     render json: { 
#       status: 'ignored', 
#       reason: 'Query too short (minimum 3 characters)' 
#     }, status: :unprocessable_entity
#   end

#   def check_rate_limit
#     ip = request.remote_ip
#     key = "rate_limit:#{ip}"
#     current = REDIS.incr(key)

#     if current > RATE_LIMIT
#       render json: { error: "Rate limit exceeded" }, status: :too_many_requests
#     else
#       REDIS.expire(key, 1.minute) if current == 1
#     end
#   end

#   def store_in_redis(key, query)
#     REDIS.multi do
#       REDIS.zadd(key, Time.now.to_i, query)
#       REDIS.expire(key, SEARCH_DEBOUNCE)
#     end
#   end

#   def redis_queries(ip)
#     REDIS.zrange("search_session:#{ip}", 0, -1)
#          .tally
#          .transform_keys(&:to_s)
#   end
# end

class SearchQueriesController < ApplicationController
  before_action :throttle_requests, only: [:create]

  def create
    query = params[:query].to_s.strip
    ip = request.remote_ip

    if query.length >= 3
      SearchQuery.record_search(query, ip)
      render json: { status: 'recorded' }
    else
      render json: { status: 'ignored' }, status: :ok
    end
  end

 def analytics
  analytics = Rails.cache.fetch("analytics/#{request.remote_ip}", expires_in: 5.seconds) do
    SearchQuery.user_analytics(request.remote_ip)
  end
  render json: { searches: analytics }
end

  private

  def throttle_requests
    key = "throttle:#{request.remote_ip}"
    count = REDIS.incr(key)
    
    if count > 30 # 30 requests per minute
      render json: { error: 'Too many requests' }, status: :too_many_requests
    else
      REDIS.expire(key, 1.minute) if count == 1
    end
  end
end