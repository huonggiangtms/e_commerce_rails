class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  belongs_to :cart

  enum :status, { pending: 0, paid: 1, failed: 2, cancelled: 3, confirmed: 4, delivered: 5 }

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }, format: { with: /\A[\p{L}\s]+\z/, message: "chỉ được chứa chữ cái và khoảng trắng" }
  validates :phone, presence: true, format: { with: /\A0\d{9}\z/, message: "phải là số điện thoại Việt Nam hợp lệ (10 chữ số, bắt đầu bằng 0)" }
  validates :address, presence: true, length: { minimum: 10, message: "phải bao gồm tỉnh/thành phố, quận/huyện, phường/xã và địa chỉ chi tiết, nếu sai chúng tôi không chịu trách nhiệm " }

  def can_request_cancellation?
    status.in?(%w[pending paid failed]) && !cancellation_requested?
  end
end
