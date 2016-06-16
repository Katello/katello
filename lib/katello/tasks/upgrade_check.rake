DESIRED_VERSION = Gem::Version.new("2.4.3")
CP_LISTEN_ACTION = "Actions::Candlepin::ListenOnCandlepinEvents"

def current_version
  Gem::Version.new(Katello::VERSION)
end

namespace :katello do
  task :upgrade_check => ['environment'] do
    desc "Task that can be run before upgrading to Katello 3.0 to check if system is upgrade ready"
    success = "PASS"
    fail = "FAIL"

    puts "This script makes no modifications and can be re-run multiple times for the most up to date results."
    puts "Checking upgradeability...\n\n"

    # check for any running tasks
    task_count = ::ForemanTasks::Task.active.where("label != '#{CP_LISTEN_ACTION}'").count
    task_status = task_count > 1 ? fail : success
    puts "Checking for running tasks..."
    puts "[#{task_status}] - There are #{task_count} active tasks.\n\n"

    # check the current version
    version_status = current_version >= DESIRED_VERSION ? success : fail
    puts "Checking the current version..."
    puts "[#{version_status}] - Current version of Katello is #{current_version} " \
      "and needs to greater than or equal to #{DESIRED_VERSION}\n\n"

    # run the content host check
    puts "Checking content hosts..."
    Rake::Task["katello:preupgrade_content_host_check"].invoke

    FileUtils.touch('/var/lib/foreman/3.0_upgrade_ready')
  end
end
