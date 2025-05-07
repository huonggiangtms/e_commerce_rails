class CreateChatbotMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :chatbot_messages do |t|
      t.references :chatbot_conversation, null: false, foreign_key: true
      t.string :sender
      t.text :content

      t.timestamps
    end
  end
end
