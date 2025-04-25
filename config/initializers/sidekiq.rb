require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  schedule_file = "config/sidekiq.yml"

  if File.exist?(schedule_file)
    # Đảm bảo file YAML được load đúng và có khả năng truy cập key theo kiểu symbol hoặc string
    raw_config = YAML.load_file(schedule_file).with_indifferent_access

    # Đảm bảo bạn có phần :schedule đúng trong cấu hình
    Sidekiq.schedule = raw_config[:scheduler][:schedule]

    # Tự động reload lại lịch trình
    Sidekiq::Scheduler.reload_schedule!
  end
end
