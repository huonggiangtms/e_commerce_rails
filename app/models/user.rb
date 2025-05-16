class User < ApplicationRecord
  has_many :chatbot_conversations, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy

  rolify
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable
  after_create :assign_default_role

  def assign_default_role
    self.add_role(:user) if self.roles.blank?
  end
end
