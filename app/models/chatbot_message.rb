class ChatbotMessage < ApplicationRecord
  belongs_to :chatbot_conversation

  validates :sender, inclusion: { in: %w[user bot] }
  validates :content, presence: true
end
