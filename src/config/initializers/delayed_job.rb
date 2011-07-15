Delayed::Worker.logger =
  ActiveSupport::BufferedLogger.new("log/#{Rails.env}_delayed_jobs.log", Rails.logger.level)
Delayed::Worker.logger.auto_flushing = 1

# models have to use logger.info instead of Rails.logger.info in order for the desired log file to be used.
if caller.last =~ /.*\/script\/delayed_job:\d+$/
  ActiveRecord::Base.logger = Delayed::Worker.logger
end

Delayed::Worker.destroy_failed_jobs = false
