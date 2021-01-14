require File.expand_path("../engine", File.dirname(__FILE__))
require "#{Katello::Engine.root}/app/services/katello/pulp3/migration_switchover"

namespace :katello do
  desc "Runs a Pulp 3 migration of pulp3 hrefs to pulp ids for supported content types."
  task :pulp3_content_switchover => ["dynflow:client"] do
    dryrun = ENV['DRYRUN']
    begin
      User.current = User.anonymous_admin

      ActiveRecord::Base.transaction do
        switchover_service = Katello::Pulp3::MigrationSwitchover.new(SmartProxy.pulp_primary)
        switchover_service.run
        fail "Dryrun completed without error, aborting and rolling back" if dryrun
      end
    rescue Katello::Pulp3::SwitchOverError => e
      $stderr.print(e.message)
      exit 1
    end

    task = ForemanTasks.sync_task(Actions::Pulp3::ContentGuard::RefreshAllDistributions, SmartProxy.pulp_primary)
    until !task.pending? || task.paused?
      sleep(10)
      task = ForemanTasks::Task.find(task.id)
    end
    if task.result == 'error' || task.result == 'pending'
      msg _("Content Guard Configuration failed, switchover aborted.  Switchover continuing, but after completion, you will want to investigate: https://#{Socket.gethostname}/foreman_tasks/tasks/#{task.id}")
      Rails.logger.error(msg)
      $stderr.print(msg)
    else
      puts _("Content Switchover completed successfully")
    end
  end
end
