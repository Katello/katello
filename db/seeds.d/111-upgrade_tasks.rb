UpgradeTask.define_tasks(:katello) do
  [
    {:name => 'katello:correct_repositories', :long_running => true, :skip_failure => true, :always_run => true},
    {:name => 'katello:correct_puppet_environments', :long_running => true, :skip_failure => true, :always_run => true},
    {:name => 'katello:clean_backend_objects', :long_running => true, :skip_failure => true, :always_run => true},
    {:name => 'katello:upgrades:3.9:migrate_sync_plans'}
  ]
end
