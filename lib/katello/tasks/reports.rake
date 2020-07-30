load "#{Rails.root}/lib/tasks/reports.rake"

#define this task since its not in foreman 2.1
namespace :dynflow do
  desc <<~END_DESC
    Sets up the environment to act as a Dynflow client. By acting as a client, it still send tasks to be processed, but it cannot execute tasks.
  END_DESC
  task :client do
    dynflow = ::Rails.application.dynflow
    dynflow.config.remote = true
    dynflow.initialize!
  end
end

#Katello reports can generate a foreman task, so mark the task as a dynflow client
["reports:daily", "reports:weekly", "reports:monthly"].each { |task| Rake::Task[task] .enhance ["dynflow:client"] }
