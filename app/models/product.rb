class Product < ApplicationRecord
  belongs_to :category
  belongs_to :crawled_product
end
