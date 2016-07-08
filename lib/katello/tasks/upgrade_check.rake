CP_LISTEN_ACTION = "Actions::Candlepin::ListenOnCandlepinEvents".freeze

namespace :katello do
  task :upgrade_check => ['environment'] do
    desc "Task that can be run before upgrading Katello to check if system is upgrade ready"
    success = "PASS"
    fail = "FAIL"

    puts "This script makes no modifications and can be re-run multiple times for the most up to date results."
    puts "Checking upgradeability...\n\n"

    # check for any running tasks
    task_count = ::ForemanTasks::Task.active.where("label != '#{CP_LISTEN_ACTION}'").count
    task_status = task_count > 0 ? fail : success
    puts "Checking for running tasks..."
    puts "[#{task_status}] - There are #{task_count} active tasks.\n\n"
  end
end
