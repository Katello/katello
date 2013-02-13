require 'katello_logging'

# Models have to use logger.info instead of Rails.logger.info in order for the desired log file to be used.
# When running under Rails last caller is "/usr/share/katello/config.ru:1" but when running standalone
# last caller is "script/delayed_job:3".

if caller.last =~ /script\/delayed_job:\d+$/ ||
    (caller[-10..-1].any? {|l| l =~ /\/rake/} && ARGV.include?("jobs:work"))
  Rails.logger = Delayed::Worker.logger = Rails.logger
  ActiveRecord::Base.logger = Rails.logger
  Glue.logger = Rails.logger
  Logging.logger.root.appenders = Katello::Logging.new.configure_appenders()
end

Delayed::Worker.destroy_failed_jobs = false

class Delayed::Worker
  def handle_failed_job_with_loggin(job, error)
    handle_failed_job_without_loggin(job,error)
    Delayed::Worker.logger.error(error.message)
    Delayed::Worker.logger.error(error.backtrace.join("\n"))
  end
  alias_method_chain :handle_failed_job, :loggin
end
