class CreateSearchQueries < ActiveRecord::Migration[8.0]
  def change
    create_table :search_queries do |t|
      t.string :query
      t.string :ip_address
      t.boolean :is_complete

      t.timestamps
    end
  end
end
