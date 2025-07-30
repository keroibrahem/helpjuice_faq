# class SearchQuery < ApplicationRecord
#   validates :query, presence: true
#   validates :ip_address, presence: true
#   validates :query, uniqueness: { scope: :ip_address }

#   # More efficient query for finding related searches
#   def self.record_with_relations(query, ip)
#     transaction do
#       # Find the most recent related query using SQL for better performance
#       related = where(ip_address: ip)
#                 .where("? LIKE query || '%'", query)
#                 .order(created_at: :desc)
#                 .first

#       if related && query.length > related.query.length
#         related.update(query: query)
#         related
#       else
#         create(query: query, ip_address: ip)
#       end
#     end
#   end

#   # Class method for analytics reporting
#   def self.user_search_analytics(ip)
#     where(ip_address: ip)
#       .group(:query)
#       .order('count_all DESC')
#       .count
#   end
# end

class SearchQuery < ApplicationRecord
  validates :query, presence: true
  validates :ip_address, presence: true

  # Case-insensitive search for existing queries
  def self.similar_query_exists?(query, ip)
    where(ip_address: ip)
      .where("LOWER(query) LIKE LOWER(?)", "#{query}%")
      .exists?
  end

  # Records only final complete searches
  def self.record_search(query, ip)
    normalized_query = query.strip.downcase
    
    # Skip if too short or already exists as part of longer query
    return if normalized_query.length < 3 || 
              similar_query_exists?(query, ip)

    # Find and update any existing partial query
    existing = where(ip_address: ip)
               .where("LOWER(?) LIKE LOWER(query) || '%'", query)
               .order('LENGTH(query) DESC')
               .first

    if existing && query.length > existing.query.length
      existing.update(query: query)
    else
      create(query: query, ip_address: ip)
    end
  end

  # Gets analytics data for UI
  def self.user_analytics(ip)
    where(ip_address: ip)
      .select('query, COUNT(*) as search_count')
      .group(:query)
      .order('search_count DESC, MAX(created_at) DESC')
      .limit(20)
      .map { |r| [r.query, r.search_count] }
      .to_h
  end
end