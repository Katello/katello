UpgradeTask.define_tasks(:katello) do
  [
    {:name => 'katello:correct_repositories', :long_running => true, :skip_failure => true, :always_run => true},
    {:name => 'katello:correct_puppet_environments', :long_running => true, :skip_failure => true, :always_run => true},
    {:name => 'katello:clean_backend_objects', :long_running => true, :skip_failure => true, :always_run => true},
    {:name => 'katello:upgrades:3.8:clear_checksum_type'},
    {:name => 'katello:upgrades:3.9:migrate_sync_plans'},
    {:name => 'katello:upgrades:3.10:clear_invalid_repo_credentials'}
  ]
end
