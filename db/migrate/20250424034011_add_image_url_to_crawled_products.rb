class AddImageUrlToCrawledProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :crawled_products, :image_url, :string
  end
end
