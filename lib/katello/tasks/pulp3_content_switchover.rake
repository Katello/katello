require File.expand_path("../engine", File.dirname(__FILE__))
require "#{Katello::Engine.root}/app/services/katello/pulp3/migration_switchover"

namespace :katello do
  desc "Runs a Pulp 3 migration of pulp3 hrefs to pulp ids for supported content types."
  task :pulp3_content_switchover => ["dynflow:client", "check_config"] do
    dryrun = ENV['DRYRUN']

    if !SETTINGS[:katello][:use_pulp_2_for_content_type][:docker] &&
        !SETTINGS[:katello][:use_pulp_2_for_content_type][:file] &&
        !SETTINGS[:katello][:use_pulp_2_for_content_type][:yum] &&
        !SETTINGS[:katello][:use_pulp_2_for_content_type][:deb]
      puts "Switchover is already complete, skipping switchover task."
    else
      begin
        User.current = User.anonymous_admin

        switchover_service = Katello::Pulp3::MigrationSwitchover.new(SmartProxy.pulp_primary)
        switchover_service.remove_orphaned_content #run out of transaction for easier re-run
        ActiveRecord::Base.transaction do
          switchover_service.run
          fail "Dryrun completed without error, aborting and rolling back" if dryrun
        end
      rescue Katello::Pulp3::SwitchOverError => e
        $stderr.print(e.message)
        exit 1
      end

      task = ForemanTasks.async_task(Actions::Pulp3::ContentGuard::RefreshAllDistributions, SmartProxy.pulp_primary)
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
end
