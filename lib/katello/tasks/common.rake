namespace :katello do
  task :disable_dynflow do
    #Ensures that we run as a dynflow 'client'
    ::Rails.application.dynflow.initialize!
    ForemanTasks.dynflow.config.remote = true
  end
end
