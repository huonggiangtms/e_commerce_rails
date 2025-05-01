class Product < ApplicationRecord
  belongs_to :category
  belongs_to :crawled_product, optional: true

  def self.ransackable_attributes(auth_object = nil)
    %w[name description price stock category_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[category]
  end
end
