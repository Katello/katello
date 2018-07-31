namespace :katello do
  task :update_sync_notifications => ['environment'] do
    desc "Task that can be run to update pulp sync notifier"
    User.current = User.anonymous_api_admin
    puts ::Katello::Repository.ensure_sync_notification
    puts "Update completed"
  end
end
