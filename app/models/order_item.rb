class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validate :check_stock, on: :create

  private

  def check_stock
    if quantity && product && quantity > product.stock
      errors.add(:quantity, "vượt quá số lượng tồn kho (chỉ còn #{product.stock} sản phẩm)")
    end
  end
end
