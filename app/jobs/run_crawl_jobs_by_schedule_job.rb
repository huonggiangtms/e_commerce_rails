class RunCrawlJobsByScheduleJob < ApplicationJob
  queue_as :default

  def perform(schedule)
    CrawlJob.where(schedule: schedule, active: true).find_each do |job|
      Rails.logger.info "Enqueued crawl for: #{job.url}"
      ProductCrawlerJob.perform_later(job.url)
    end
  end
end
