class Faq < ApplicationRecord
  validates :question, :answer, presence: true
  scope :active, -> { where(active: true) }

  CATEGORIES = {
    'shipping' => 'Vận chuyển',
    'return_policy' => 'Đổi trả',
    'payment' => 'Thanh toán',
    'warranty' => 'Bảo hành',
    'account' => 'Tài khoản',
    'promotion' => 'Khuyến mãi',
    'general' => 'Khác'
  }.freeze
end
