class CreateCrawledProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :crawled_products do |t|
      t.string :name
      t.decimal :price
      t.text :description
      t.integer :stock
      t.string :category_name
      t.string :status

      t.timestamps
    end
  end
end
