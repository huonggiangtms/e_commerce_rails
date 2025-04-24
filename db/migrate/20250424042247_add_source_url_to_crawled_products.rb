class AddSourceUrlToCrawledProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :crawled_products, :source_url, :string
    add_index :crawled_products, :source_url, unique: true
  end
end
