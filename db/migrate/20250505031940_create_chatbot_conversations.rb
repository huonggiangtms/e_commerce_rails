class CreateChatbotConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :chatbot_conversations do |t|
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
