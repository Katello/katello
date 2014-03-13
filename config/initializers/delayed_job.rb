# Models have to use logger.info instead of Rails.logger.info in order for the desired log file to be used.

if defined?(Delayed)
  Delayed::Worker.destroy_failed_jobs = false

  Delayed::Worker.backend = :active_record

  class Delayed::Worker
    def handle_failed_job_with_loggin(job, error)
      handle_failed_job_without_loggin(job, error)
      Delayed::Worker.logger.error(error.message)
      Delayed::Worker.logger.error(error.backtrace.join("\n"))
    end
    alias_method_chain :handle_failed_job, :loggin

    class << self
      def after_fork_with_dynflow(*args)
        after_fork_without_dynflow(*args)
        if ForemanTasks.dynflow.initialized?
          # Delayed jobs runs with daemons which means we need to reinitialize
          # the world after forking to reopen the db connection
          ForemanTasks.dynflow.reinitialize!
        end
      end
      alias_method_chain :after_fork, :dynflow
    end
  end
end
