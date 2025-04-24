require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  config.on(:startup) do
    schedule_file = Rails.root.join('config', 'sidekiq.yml')

    if File.exist?(schedule_file)
      # Thiết lập chế độ dynamic schedule cho Sidekiq Scheduler
      Sidekiq::Scheduler.dynamic = true

      # Tải cấu hình schedule từ file YAML
      Sidekiq.schedule = YAML.load_file(schedule_file).dig('scheduler', 'schedule') || {}

      # Tải lại lịch trình (reload) cho sidekiq-scheduler
      Sidekiq::Scheduler.reload_schedule!
    else
      Rails.logger.error "Sidekiq schedule file not found: #{schedule_file}"
    end
  end
end
