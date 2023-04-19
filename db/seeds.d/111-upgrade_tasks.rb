UpgradeTask.define_tasks(:katello) do
  [
    {:name => 'katello:correct_repositories', :long_running => true, :skip_failure => true, :always_run => true},
    {:name => 'katello:clean_backend_objects', :long_running => true, :skip_failure => true, :always_run => true},
    {:name => 'katello:upgrades:4.0:remove_ostree_puppet_content'},
    {:name => 'katello:upgrades:4.1:sync_noarch_content'},
    {:name => 'katello:upgrades:4.1:fix_invalid_pools'},
    {:name => 'katello:upgrades:4.1:reupdate_content_import_export_perms'},
    {:name => 'katello:upgrades:4.2:remove_checksum_values'},
    {:name => 'katello:upgrades:4.4:publish_import_cvvs'},
    {:name => 'katello:upgrades:4.8:fix_incorrect_providers'},
    {:name => 'katello:upgrades:4.8:regenerate_imported_repository_metadata'},
    {:name => 'katello:upgrades:4.9:update_custom_products_enablement'}
  ]
end
