namespace :katello do
  desc "Reset the Pulp 2 -> Pulp 3 migration for content types that haven't been fully switched over"
  task :pulp3_migration_reset => ["dynflow:client", "check_ping"] do
    puts "Starting Content Migration Reset."
    SmartProxy.pulp_primary.refresh

    task = ForemanTasks.async_task(Actions::Pulp3::ContentMigrationReset, SmartProxy.pulp_primary)

    if ENV['wait'].nil? || ::Foreman::Cast.to_bool(ENV['wait'])
      until !task.pending? || task.paused?
        sleep(20)
        task = ForemanTasks::Task.find(task.id)
      end

      if task.result == 'warning' || task.result == 'pending'
        msg = _("Content Migration Reset failed, You will want to investigate: https://#{Socket.gethostname}/foreman_tasks/tasks/#{task.id}\n")
        $stderr.print(msg)
        fail ForemanTasks::TaskError, task
      else
        puts _("Content Migration Reset completed successfully")
      end
    else
      puts "Content Migration Reset started, you may monitor it at: https://#{Socket.gethostname}/foreman_tasks/tasks/#{task.id}"
    end
  end
end
