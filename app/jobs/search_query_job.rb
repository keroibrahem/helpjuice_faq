class SearchQueryJob < ApplicationJob
  retry_on ActiveRecord::RecordNotUnique, attempts: 3
  discard_on ActiveRecord::RecordInvalid

  def perform(query, ip)
    # Skip if this IP has a longer query already
    return if SearchQuery.where(ip_address: ip)
                        .where("query LIKE ?", "#{query}%")
                        .exists?

    SearchQuery.record_final_search(query, ip)
  end
end