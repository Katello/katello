load "#{Rails.root}/lib/tasks/reports.rake"

#Katello reports can generate a foreman task, so mark the task as a dynflow client
["reports:daily", "reports:weekly", "reports:monthly"].each { |task| Rake::Task[task] .enhance ["dynflow:client"] }
