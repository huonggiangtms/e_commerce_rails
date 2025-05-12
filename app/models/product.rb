class Product < ApplicationRecord
  belongs_to :category
  belongs_to :crawled_product, optional: true

  validates :stock, numericality: { greater_than_or_equal_to: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  def self.ransackable_attributes(auth_object = nil)
    %w[name description price stock image_url category_id created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[category]
  end

  def low_stock?
    stock <= 5 && stock > 0
  end

  def out_of_stock?
    stock.zero?
  end
end
