# Models have to use logger.info instead of Rails.logger.info in order for the desired log file to be used.

if defined?(Delayed)
  Delayed::Worker.destroy_failed_jobs = false

  Delayed::Worker.backend = :active_record

  class Delayed::Worker
    def handle_failed_job_with_loggin(job, error)
      handle_failed_job_without_loggin(job,error)
      Delayed::Worker.logger.error(error.message)
      Delayed::Worker.logger.error(error.backtrace.join("\n"))
    end
    alias_method_chain :handle_failed_job, :loggin
  end
end
