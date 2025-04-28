class ChangeCrawledProductIdNullableInProducts < ActiveRecord::Migration[8.0]
  def change
    change_column_null :products, :crawled_product_id, true
  end
end
