class ProductCrawlerJob < ApplicationJob
  queue_as :default

  def perform(url)
    crawler = ProductCrawler.new(url)
    crawler.crawl_and_save
  end
end
