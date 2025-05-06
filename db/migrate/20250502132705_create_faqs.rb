class CreateFaqs < ActiveRecord::Migration[8.0]
  def change
    create_table :faqs do |t|
      t.string :question
      t.text :answer
      t.string :category
      t.boolean :active

      t.timestamps
    end
  end
end
