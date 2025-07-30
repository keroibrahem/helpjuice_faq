
class RedisToDbJob < ApplicationJob
  def perform
   
    keys = REDIS.keys("search:*")
    
    keys.each do |key|
      ip = key.split(":").last
      queries = REDIS.zrange(key, 0, -1)

      queries.each do |query|
        SearchQuery.record(query, ip) 
      end

      REDIS.del(key) 
    end
  end
end