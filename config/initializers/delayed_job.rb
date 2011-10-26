Delayed::Worker.logger =
  ActiveSupport::BufferedLogger.new("log/#{Rails.env}_delayed_jobs.log", Rails.logger.level)
Delayed::Worker.logger.auto_flushing = 1

# models have to use logger.info instead of Rails.logger.info in order for the desired log file to be used.
if caller.last =~ /.*\/script\/delayed_job:\d+$/
  ActiveRecord::Base.logger = Delayed::Worker.logger
end

Delayed::Worker.destroy_failed_jobs = false

if Rails.env == "development"
  class Delayed::Worker
    def handle_failed_job_with_loggin(job, error)
      handle_failed_job_without_loggin(job,error)
      Delayed::Worker.logger.error(error.message)
      Delayed::Worker.logger.error(error.backtrace.join("\n"))
    end
    alias_method_chain :handle_failed_job, :loggin
  end
end
