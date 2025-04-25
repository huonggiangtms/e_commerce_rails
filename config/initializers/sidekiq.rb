require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  schedule_file = "config/sidekiq.yml"

  if File.exist?(schedule_file)
    raw_config = YAML.load_file(schedule_file).with_indifferent_access

    Sidekiq.schedule = raw_config[:scheduler][:schedule]

    Sidekiq::Scheduler.reload_schedule!
  end
end
