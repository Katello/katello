load "#{Katello::Engine.root}/lib/katello/tasks/common.rake"

namespace :katello do
  desc "Runs a Pulp 2 to 3 Content Migration for supported types.  May be run multiple times.  Use wait=false to immediately return with a task url."
  task :pulp3_migration => ["environment", "disable_dynflow", "check_ping"] do
    puts "Starting task."
    SmartProxy.pulp_primary.refresh

    reimport_all = ::Foreman::Cast.to_bool(ENV['reimport_all'])
    wait = ::Foreman::Cast.to_bool(ENV['wait'] || 'true')
    preserve_output = ::Foreman::Cast.to_bool(ENV['preserve_output'])

    task = ForemanTasks.async_task(Actions::Pulp3::ContentMigration, SmartProxy.pulp_primary, reimport_all: reimport_all)

    if wait
      clear_count = nil
      until !task.pending? || task.paused?
        $stdout.print("\r#{' ' * clear_count}\r") if clear_count && !preserve_output #clear the line before printing
        $stdout.print("\n") if preserve_output
        message = "#{Time.now.to_s}: #{task.humanized[:output]}"
        clear_count = message.length + 1
        $stdout.print(message)

        sleep(10)
        task = ForemanTasks::Task.find(task.id)
      end

      if task.result == 'warning' || task.result == 'pending'
        msg = _("Migration failed, You will want to investigate: https://#{Socket.gethostname}/foreman_tasks/tasks/#{task.id}\n")
        $stderr.print(msg)
        fail ForemanTasks::TaskError, task
      else
        puts
        Katello::Pulp3::Migration::CORRUPTABLE_CONTENT_TYPES.each do |type|
          if type.missing_migrated_content.any?
            puts "Some corrupted or missing content found, run 'foreman-maintain content migration-stats' for more information."
            exit(-1)
          end
        end
        puts _("Content Migration completed successfully")
      end
    else
      puts "Migration started, you may monitor it at: https://#{Socket.gethostname}/foreman_tasks/tasks/#{task.id}"
    end
  end
end
