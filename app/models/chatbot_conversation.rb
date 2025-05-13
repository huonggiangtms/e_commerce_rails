class ChatbotConversation < ApplicationRecord
  belongs_to :user
  has_many :chatbot_messages, dependent: :destroy
end
