namespace :katello do
  desc "Runs a Pulp 2 to 3 Content Migration for supported types.  May be run multiple times.  Use wait=false to immediately return with a task url."
  task :pulp3_migration => ["environment", "disable_dynflow", "check_ping"] do
    task = ForemanTasks.async_task(Actions::Pulp3::ContentMigration)

    if ENV['wait'].nil? || ::Foreman::Cast.to_bool(ENV['wait'])
      until !task.pending? || task.paused?
        sleep(20)
        task = ForemanTasks::Task.find(task.id)
      end

      if task.result == 'error' || task.result == 'pending'
        fail ForemanTasks::TaskError, task
      else
        puts _("Content Migration completed successfully")
      end
    else
      puts "Migration started, you may monitor it at: https://#{Socket.gethostname}/foreman_tasks/tasks/#{task.id}"
    end
  end
end
