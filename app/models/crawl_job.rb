class CrawlJob < ApplicationRecord
  validates :url, presence: true
  validates :schedule, inclusion: {
    in: %w[every_1am every_8am every_5pm every_1615],
    message: "%{value} is not a valid schedule"
  }

  scope :active, -> { where(active: true) }
end
