class CreateCrawlJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :crawl_jobs do |t|
      t.string :url
      t.string :schedule
      t.boolean :active

      t.timestamps
    end
  end
end
